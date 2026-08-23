# Core kernix options -- cross-cutting identity and preferences.
# These are read by multiple modules across system/ and home/.
# Feature-specific options are declared by each module's options.nix
# and aggregated by system/options.nix.
{lib, ...}:
with lib; {
  options.kernix = {
    # ── Identity ──
    username = mkOption {
      type = types.str;
      description = "System username for this host.";
    };

    gpu = mkOption {
      type = types.enum ["nvidia" "intel" "amd" "none"];
      default = "none";
      description = "GPU driver to use. Configures drivers, kernel modules, and VAAPI.";
    };

    # ── System ──
    timezone = mkOption {
      type = types.str;
      default = "America/New_York";
      description = "System timezone.";
    };

    locale = mkOption {
      type = types.str;
      default = "en_US.UTF-8";
      description = "System locale.";
    };

    homePrefix = mkOption {
      type = types.str;
      default = "/home";
      description = "Home directory prefix (e.g. /home on Linux, /Users on macOS).";
    };

    kernixRoot = mkOption {
      type = types.str;
      default = "";
      description = "Override for the kernix config root directory. Empty to auto-derive.";
    };

    # ── Preferences (read by multiple HM and system modules) ──
    terminal = mkOption {
      type = types.enum ["ghostty" "kitty" "alacritty" "foot"];
      default = "ghostty";
      description = "Terminal emulator.";
    };

    defaultTheme = mkOption {
      type = types.str;
      default = "ayu-dark";
      description = "Default theme (from themes/).";
    };

    font = {
      monospace = mkOption {
        type = types.str;
        default = "Maple Mono NF";
        description = "Monospace font family.";
      };
    };

    git = {
      name = mkOption {
        type = types.str;
        default = "user";
        description = "Git author name for commits.";
      };
      email = mkOption {
        type = types.str;
        default = "user@localhost";
        description = "Git author email for commits.";
      };
    };

    opencode = {
      vertexProject = mkOption {
        type = types.str;
        default = "";
        description = "GCP project ID for Vertex AI. Empty to disable.";
      };
      cloudMlRegion = mkOption {
        type = types.str;
        default = "global";
        description = "Cloud ML region for OpenCode.";
      };
    };

    # ── Passthrough ──
    nixtorch = mkOption {
      type = types.attrs;
      default = {};
      description = "Configuration passed directly to nixtorch.lib.mkDevShell.";
    };
  };
}
