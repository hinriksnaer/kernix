# Battle.net launcher + World of Warcraft (Forever) via umu-launcher.
# Upstream: github:jacobjdowning/battlenet-umu (flake input).
#
# Every entry in `games` becomes a `<game>-umu` package plus a desktop entry.
# The launch script installs Battle.net into the Wine prefix on first run
# (default: ~/.local/share/battlenet-umu/prefix) and then starts the given
# exe inside it -- games themselves are installed through the launcher, not
# by Nix, so the paths below only need to match Battle.net's defaults.
#
# Add-ons are managed by instawow: `sync-addons` (a systemd user service run
# at boot) reconciles each declared profile against the AddOns folder, so the
# lists below are authoritative -- anything not declared gets removed.
#
# The flake's `homeModules.default` pins instawow 7.3.0 (built from the PyPI
# sdist), the version that understands WoW Forever: product `wowf`, install
# subfolder `_forever_`, flavour `forever_classic` (CurseForge type id 88568).
#
# CurseForge access without an API key: https://api.curseforge.com answers 403
# unauthenticated, and instawow would otherwise send `addons.tokens.cfcore` as
# the x-api-key header -- i.e. the key would sit in plaintext in the nix store.
# instawow has a proxy hook for exactly this: when INSTAWOW_CF_API_URL is set
# it talks to that base URL instead and never sends a key. Curse.tools runs
# such a proxy with their own key server-side, so the variables below point
# instawow at it and no token is needed anywhere. Verified end to end:
# instawow 7.3.0 installs curse:restedxp-guide with no tokens configured.
# To own the key instead, drop both variables and set tokens.cfcore.
{
  lib,
  pkgs,
  host,
  battlenet-umu,
  ...
}: let
  # Curse.tools moved its CurseForge-compatible API from `/v1/cf` to `/v1`
  # (the old path now 302-redirects to `http://.../v1`, which instawow's POST
  # lands on as a bodiless GET -> 404 "Not Found, url='.../v1/mods'").
  cfProxy = "https://api.curse.tools/v1";

  # $HOME-relative location of the Forever AddOns folder. `addonDir` above is
  # prefix-relative because instawow runs against the Wine prefix, so the two
  # cannot share one value.
  wowAddons = ".local/share/battlenet-umu/prefix/drive_c/Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns";
in {
  imports = [battlenet-umu.homeModules.default];

  config = lib.mkIf host.gaming.enable {
    programs.battlenet-umu = {
      enable = true;

      games = [
        {name = "Battle.net";}
        {
          name = "World of Warcraft: Forever";
          path = "Program Files (x86)/World of Warcraft/_forever_/Wow.exe";
        }
      ];

      addons = {
        enable = true;
        versions = [
          {
            name = "forever";
            addonDir = "Program Files (x86)/World of Warcraft/_forever_/Interface/AddOns";
            flavour = "forever_classic";
            addons = [
              "curse:restedxp-guide"
              "curse:guild-os"
              "curse:details"
              "curse:tradeskill-master"
              # Price feeds for TSM. TSM has no AuctionDB data for Forever: its
              # full-scan module has no FOREVER branch (LibTSMService/Source/
              # Auction/Internal/FullScan.lua) and the desktop app receives
              # nothing for the Forever markets, so `dbmarket`/`dbhistorical`
              # are always 0. Instead:
              #
              #   AHledger    - per-market price tables (incl. rppvp/horde/us)
              #                 refreshed every ~30 min, exposed to TSM by the
              #                 bridge below as OERealm/OERegion.
              #   Auctionator - local scans, exposed by TSM as `AtrValue`; the
              #                 fallback for items AHledger has not priced.
              "curse:ahledger"
              "curse:auctionator"
            ];
          }
        ];
      };
    };

    # TSM accepts external price databases only through four hardcoded hooks
    # (LibTSMApp/Source/Price/External.lua), and the Oribos Exchange one is the
    # only fit for an "usual price + current cheapest" pair:
    #
    #   Addon.IsEnabled("OribosExchange") and _G.OEMarketInfo(link, temp)
    #     -> OERealm  = data.market = AHledger median  (the usual price)
    #     -> OERegion = data.region = AHledger minBuyout (current cheapest)
    #
    # Hence the folder name below is load-bearing, and it must sort before
    # TradeSkillMaster so the global exists when TSM registers its sources.
    # instawow's sync only removes addons it installed itself, so this folder
    # survives `sync-addons`.
    #
    # AHledger's terms require crediting the source wherever these prices show;
    # `/oebridge` prints the credit in game. TSM caches price-database sources
    # per session, so `/reload` after AHledger syncs to pick up new numbers.
    home.file."${wowAddons}/OribosExchange/OribosExchange.toc".text = ''
      ## Interface: 16001
      ## Title: TSM Oribos Bridge
      ## Notes: Exposes AHledger prices to TradeSkillMaster as OERealm/OERegion.
      ## Version: 1
      ## OptionalDeps: AHledger, TradeSkillMaster
      OribosExchange.lua
    '';

    home.file."${wowAddons}/OribosExchange/OribosExchange.lua".text = ''
      -- Exposes AHledger's per-market prices to TradeSkillMaster.
      --
      -- TSM evaluates every price source through CustomString; the external ones
      -- it will register are fixed in LibTSMApp/Source/Price/External.lua. The
      -- Oribos Exchange branch checks for this addon's name and this global, so
      -- both are load-bearing; do not rename.
      --
      --   OERealm  = median     (what the item usually sells for)
      --   OERegion = minBuyout  (cheapest listing AHledger last saw)
      --
      -- All values are copper. AHledgerAPI is nil when AHledger is disabled or
      -- still loading, so every path here degrades to "no price" rather than an
      -- error inside TSM's price evaluation.

      local API_CREDIT = "Prices from AHledger (ahledger.com)"

      --- Called by TSM for each item while evaluating a price source.
      -- @param itemLink item link from TSM's ItemInfo.GetLink
      -- @param temp     reusable table supplied by TSM
      function OEMarketInfo(itemLink, temp)
          if not AHledgerAPI or type(itemLink) ~= "string" then
              return nil
          end
          local price = AHledgerAPI.GetPrice(itemLink)
          if not price then
              return nil
          end
          temp = type(temp) == "table" and temp or {}
          temp.market = price.median
          temp.region = price.minBuyout
          return temp
      end

      SLASH_ORIBOSBRIDGE1 = "/oebridge"
      SlashCmdList["ORIBOSBRIDGE"] = function()
          local ok = AHledgerAPI and AHledgerAPI.GetTableInfo and AHledgerAPI.GetMarket
          if not ok then
              print("TSM Oribos bridge: AHledger not loaded (is the addon enabled?)")
              return
          end
          local market = AHledgerAPI.GetMarket()
          local info = AHledgerAPI.GetTableInfo(market) or {}
          print(("|cff33ff99TSM Oribos bridge|r: %s"):format(API_CREDIT))
          print(("market=%s items=%s snapshot=%s"):format(
              tostring(market), tostring(info.count), tostring(info.snapshot)))
      end
    '';

    # Read by instawow at import time. The boot-time sync service does not
    # inherit shell variables, so it needs its own copy; sessionVariables
    # covers manual `sync-addons forever` / `instawow -p forever update`.
    home.sessionVariables.INSTAWOW_CF_API_URL = cfProxy;
    systemd.user.services.wow-addon-sync.Service.Environment = [
      "INSTAWOW_CF_API_URL=${cfProxy}"
    ];
  };
}
