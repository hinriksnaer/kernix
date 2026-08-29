# Bare-metal boot and system service configuration.
{
  config,
  lib,
  ...
}:
lib.mkIf config.kernix.hardware.enable {
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Disable kernel audit subsystem (not needed on single-user desktop).
  boot.kernelParams = ["audit=0"];

  services.dbus.enable = true;
}
