# Firefox with Vimium (vim bindings) and Proton Pass.
# Extensions are fetched from addons.mozilla.org and installed declaratively.
{ pkgs, config, ... }:

let
  # Minimal builder for Firefox XPI addons (avoids NUR dependency).
  buildFirefoxXpiAddon = { pname, version, addonId, url, hash }:
    pkgs.stdenv.mkDerivation {
      inherit pname version;
      src = pkgs.fetchurl { inherit url hash; };
      preferLocalBuild = true;
      allowSubstitutes = true;
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
      passthru = { inherit addonId; };
    };

  vimium = buildFirefoxXpiAddon {
    pname = "vimium-ff";
    version = "2.4.2";
    addonId = "{d7742d87-e61d-4b78-b8a1-b469842139fa}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4717567/vimium_ff-2.4.2.xpi";
    hash = "sha256-Ex4qZ1gOeukSWrGXgRWeYUCfrEe0Qfwngqq3Y5bq0ZY=";
  };

  proton-pass = buildFirefoxXpiAddon {
    pname = "proton-pass";
    version = "1.36.1";
    addonId = "78272b6fa58f4a1abaac99321d503a20@proton.me";
    url = "https://addons.mozilla.org/firefox/downloads/file/4768005/proton_pass-1.36.1.xpi";
    hash = "sha256-Tfog/GaYEU1ONqlkWU22577HS/1bh5QuM6V/JCtguwQ=";
  };

  ayu-dark = buildFirefoxXpiAddon {
    pname = "ayu-dark-theme";
    version = "1.0";
    addonId = "{893ac7d8-44d2-4f3c-8a40-d42cef042076}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3972754/ayu_dark_theme-1.0.xpi";
    hash = "sha256-3Wz8TY2pd/K6HEP1T3f5iszCZRB15G69Gxotm5hPVQA=";
  };
in
{
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    profiles.default = {
      isDefault = true;

      extensions.packages = [
        vimium
        proton-pass
        ayu-dark
      ];

      settings = {
        # Unblock Vimium on Mozilla domains (addons.mozilla.org, etc.)
        # about:* pages remain blocked -- that's hardcoded in Firefox.
        "extensions.webextensions.restrictedDomains" = "";

        # Disable clutter.
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.tabs.firefox-view" = false;
      };
    };
  };
}
