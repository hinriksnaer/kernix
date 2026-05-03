# Typed option declarations for all configuration.
# Global values are set in settings.nix. Per-host values are set by each host
# config reading from kernix.hosts.<name>. Type errors are caught at evaluation time.
{lib, ...}:
with lib; let
  # Monitor submodule (shared between kernix.hosts.<name>.monitors and HM config.monitors)
  monitorSubmodule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        default = "";
        description = "Output name (e.g. HDMI-A-1). Empty for auto.";
      };
      resolution = mkOption {
        type = types.str;
        default = "preferred";
        description = "Resolution (e.g. 7680x2160@120).";
      };
      position = mkOption {
        type = types.str;
        default = "auto";
        description = "Position (e.g. 0x0, auto).";
      };
      scale = mkOption {
        type = types.float;
        default = 1.0;
        description = "Scale factor.";
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Primary monitor.";
      };
      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Whether enabled.";
      };
      workspace = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Default workspace.";
      };
    };
  };

  # Per-host settings submodule
  hostModule = types.submodule {
    options = {
      username = mkOption {
        type = types.str;
        description = "System username for this host.";
      };
      gpu = mkOption {
        type = types.enum ["nvidia" "intel" "amd" "none"];
        default = "none";
        description = "GPU driver to use on this host.";
      };
      monitors = mkOption {
        type = types.listOf monitorSubmodule;
        default = [
          {
            name = "";
            resolution = "preferred";
            position = "auto";
            scale = 1.0;
            primary = true;
          }
        ];
        description = "Monitor configurations for this host.";
      };
      cudaVisibleDevices = mkOption {
        type = types.str;
        default = "";
        description = "CUDA_VISIBLE_DEVICES for remote dev hosts. Empty to use all.";
      };
      projects = mkOption {
        type = types.attrsOf types.attrs;
        default = {};
        description = "Dev project configurations for this host.";
      };
    };
  };
in {
  options.kernix = {
    # ── Active host options (set by each host config) ──
    username = mkOption {
      type = types.str;
      description = "System username. Set per-host from settings.nix hosts section.";
    };

    gpu = mkOption {
      type = types.enum ["nvidia" "intel" "amd" "none"];
      default = "none";
      description = "GPU driver to use. Configures drivers, kernel modules, and VAAPI.";
      example = "nvidia";
    };

    # ── Global settings (shared across all hosts) ──
    defaultTheme = mkOption {
      type = types.str;
      default = "ayu-dark";
      description = "Default theme (from themes/). Consumed by Home Manager.";
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
      vertexRegion = mkOption {
        type = types.str;
        default = "us-east5";
        description = "GCP region for Vertex AI.";
      };
      cloudMlRegion = mkOption {
        type = types.str;
        default = "global";
        description = "Cloud ML region for OpenCode.";
      };
    };

    # ── Per-host settings (type-checked submodule) ──
    hosts = mkOption {
      type = types.attrsOf hostModule;
      default = {};
      description = "Per-host settings keyed by host name. Each entry is type-checked.";
    };
  };
}
