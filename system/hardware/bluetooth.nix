# Bluetooth -- system-level only.
# User tools (bluetui) are managed by Home Manager
# (home/desktop/hardware-tools.nix).
{...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;
}
