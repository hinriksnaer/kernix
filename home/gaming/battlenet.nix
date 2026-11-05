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
  host,
  battlenet-umu,
  ...
}: let
  cfProxy = "https://api.curse.tools/v1/cf";
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
              # RestedXP Guide -- one zip carries every flavour; its TOC lists
              # interface 16001 (Forever) alongside retail and the classics.
              "curse:restedxp-guide"
              "curse:guild-os"
            ];
          }
        ];
      };
    };

    # Read by instawow at import time. The boot-time sync service does not
    # inherit shell variables, so it needs its own copy; sessionVariables
    # covers manual `sync-addons forever` / `instawow -p forever update`.
    home.sessionVariables.INSTAWOW_CF_API_URL = cfProxy;
    systemd.user.services.wow-addon-sync.Service.Environment = [
      "INSTAWOW_CF_API_URL=${cfProxy}"
    ];
  };
}
