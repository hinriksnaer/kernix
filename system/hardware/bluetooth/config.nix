# Bluetooth -- system-level only.
# User tools (bluetui) are managed by Home Manager
# (home/desktop/hardware-tools.nix).
{config, ...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = config.kernix.hardware.bluetooth.powerOnBoot;
  };

  services.blueman.enable = true;
}
