# Bluetooth -- system-level only.
# User tools (bluetui) are managed by Home Manager
# (home/desktop/hardware-tools.nix).
{
  config,
  lib,
  ...
}:
lib.mkIf config.kernix.hardware.enable {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = config.kernix.hardware.bluetooth.powerOnBoot;
  };

  services.blueman.enable = true;
}
