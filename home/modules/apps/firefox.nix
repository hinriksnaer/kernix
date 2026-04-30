# Firefox with Vimium (vim bindings), Proton Pass, and SimpleFox theme.
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

        # Enable userChrome.css customisation.
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Disable clutter.
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.tabs.firefox-view" = false;
      };

      # SimpleFox theme (https://github.com/migueravila/SimpleFox)
      # Colors provided by the Ayu Dark theme extension.
      userChrome = ''
        :root {
          --sfwindow: #19171a;
          --sfsecondary: #201e21;
        }

        /* Urlbar View */
        .urlbarView {
          display: none !important;
        }

        /* Tabs colors */
        #tabbrowser-tabs:not([movingtab])
          > #tabbrowser-arrowscrollbox
          > .tabbrowser-tab
          > .tab-stack
          > .tab-background[multiselected="true"],
        #tabbrowser-tabs:not([movingtab])
          > #tabbrowser-arrowscrollbox
          > .tabbrowser-tab
          > .tab-stack
          > .tab-background[selected="true"] {
          background-image: none !important;
          background-color: var(--toolbar-bgcolor) !important;
        }

        /* Inactive tabs color */
        #navigator-toolbox {
          background-color: var(--sfwindow) !important;
        }

        /* Window colors */
        :root {
          --toolbar-bgcolor: var(--sfsecondary) !important;
          --tabs-border-color: var(--sfsecondary) !important;
          --lwt-sidebar-background-color: var(--sfwindow) !important;
          --lwt-toolbar-field-focus: var(--sfsecondary) !important;
        }

        /* Sidebar color */
        #sidebar-box,
        .sidebar-placesTree {
          background-color: var(--sfwindow) !important;
        }

        /* Tabs elements */
        .tab-close-button {
          display: none;
        }

        .tabbrowser-tab:not([pinned]) .tab-icon-image {
          display: none !important;
        }

        #nav-bar:not([tabs-hidden="true"]) {
          box-shadow: none;
        }

        #tabbrowser-tabs[haspinnedtabs]:not([positionpinnedtabs])
          > #tabbrowser-arrowscrollbox
          > .tabbrowser-tab[first-visible-unpinned-tab] {
          margin-inline-start: 0 !important;
        }

        :root {
          --toolbarbutton-border-radius: 0 !important;
          --tab-border-radius: 0 !important;
          --tab-block-margin: 0 !important;
        }

        .tab-background {
          border-right: 0px solid rgba(0, 0, 0, 0) !important;
          margin-left: -4px !important;
        }

        .tabbrowser-tab:is([visuallyselected="true"], [multiselected])
          > .tab-stack
          > .tab-background {
          box-shadow: none !important;
        }

        .tabbrowser-tab[last-visible-tab="true"] {
          padding-inline-end: 0 !important;
        }

        #tabs-newtab-button {
          padding-left: 0 !important;
        }

        /* Url Bar */
        #urlbar-input-container {
          background-color: var(--sfsecondary) !important;
          border: 1px solid rgba(0, 0, 0, 0) !important;
        }

        #urlbar-container {
          margin-left: 0 !important;
        }

        #urlbar[focused="true"] > #urlbar-background {
          box-shadow: none !important;
        }

        #navigator-toolbox {
          border: none !important;
        }

        /* Bookmarks bar */
        .bookmark-item .toolbarbutton-icon {
          display: none;
        }
        toolbarbutton.bookmark-item:not(.subviewbutton) {
          min-width: 1.6em;
        }

        /* Toolbar */
        #tracking-protection-icon-container,
        #urlbar-zoom-button,
        #star-button-box,
        #pageActionButton,
        #pageActionSeparator,
        #tabs-newtab-button,
        #back-button,
        #PanelUI-button,
        #forward-button,
        .tab-secondary-label {
          display: none !important;
        }

        .urlbarView-url {
          color: #dedede !important;
        }

        /* Disable context menu clutter */
        #context-navigation,
        #context-savepage,
        #context-pocket,
        #context-sendpagetodevice,
        #context-selectall,
        #context-viewsource,
        #context-inspect-a11y,
        #context-sendlinktodevice,
        #context-openlinkinusercontext-menu,
        #context-bookmarklink,
        #context-savelink,
        #context-savelinktopocket,
        #context-sendlinktodevice,
        #context-searchselect,
        #context-sendimage,
        #context-print-selection {
          display: none !important;
        }

        #context_bookmarkTab,
        #context_moveTabOptions,
        #context_sendTabToDevice,
        #context_reopenInContainer,
        #context_selectAllTabs,
        #context_closeTabOptions {
          display: none !important;
        }

        /* Remove titlebar spacers (Hyprland manages windows) */
        .titlebar-spacer {
          display: none !important;
        }
      '';

      userContent = ''
        @-moz-document url("about:newtab"), url("about:home") {
          .search-wrapper {
            display: none !important;
          }
        }
      '';
    };
  };
}
