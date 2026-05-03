# Typed option declarations for all configuration.
# Global values are set in settings.nix. Per-host values are set by each host
# config reading from hawker.hosts.<name>. Type errors are caught at evaluation time.
{ lib, ... }:

with lib;

let
  # Per-host settings submodule
  hostModule = types.submodule {
    options = {
      username = mkOption {
        type = types.str;
        description = "System username for this host.";
      };
      gpu = mkOption {
        type = types.enum [ "nvidia" "intel" "amd" "none" ];
        default = "none";
        description = "GPU driver to use on this host.";
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
in
{
  options.hawker = {
    # ── Active host options (set by each host config) ──
    username = mkOption {
      type = types.str;
      description = "System username. Set per-host from settings.nix hosts section.";
    };

    gpu = mkOption {
      type = types.enum [ "nvidia" "intel" "amd" "none" ];
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
