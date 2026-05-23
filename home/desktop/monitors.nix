# Typed monitor configuration -- consumed by hyprland.nix and other WM modules.
# Values flow from settings.nix → hosts/*/home.nix → config.monitors.
# Type definition shared with system/core/kernix-options.nix via monitor-type.nix.
{lib, ...}:
with lib; let
  monitorType = import ../../system/core/monitor-type.nix {inherit lib;};
in {
  options.monitors = mkOption {
    type = types.listOf monitorType.submodule;
    default = monitorType.default;
    description = "Monitor configurations. Set per-host in hosts/*/home.nix.";
  };
}
