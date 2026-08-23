# Desktop options -- kernix.desktop.{enable, monitors}
# Hyprland-specific options are in ./hyprland/options.nix.
{lib, ...}: let
  monitorType = import ../../lib/monitor-type.nix {inherit lib;};
in {
  options.kernix.desktop = {
    enable = lib.mkEnableOption "desktop environment (Hyprland)";

    monitors = lib.mkOption {
      type = lib.types.listOf monitorType.submodule;
      default = monitorType.default;
      description = "Monitor configurations for this host.";
    };
  };
}
