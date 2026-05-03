# Typed monitor configuration -- consumed by hyprland.nix and other WM modules.
# Values flow from settings.nix → profiles → config.monitors.
{lib, ...}:
with lib; {
  options.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          default = "";
          description = "Monitor output name (e.g. HDMI-A-1, eDP-1). Empty for auto-detect.";
        };
        resolution = mkOption {
          type = types.str;
          default = "preferred";
          description = "Resolution string (e.g. 7680x2160@120, preferred).";
        };
        position = mkOption {
          type = types.str;
          default = "auto";
          description = "Position (e.g. 0x0, auto, auto-right).";
        };
        scale = mkOption {
          type = types.float;
          default = 1.0;
          description = "Display scale factor.";
        };
        primary = mkOption {
          type = types.bool;
          default = false;
          description = "Whether this is the primary monitor.";
        };
        enabled = mkOption {
          type = types.bool;
          default = true;
          description = "Whether this monitor is enabled.";
        };
        workspace = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Default workspace for this monitor.";
        };
      };
    });
    default = [
      {
        name = "";
        resolution = "preferred";
        position = "auto";
        scale = 1.0;
        primary = true;
      }
    ];
    description = "Monitor configurations. Set per-host in profiles.";
  };
}
