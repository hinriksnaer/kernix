# Bare-metal boot and system service configuration.
{
  config,
  lib,
  ...
}:
lib.mkIf config.kernix.hardware.enable {
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  services.dbus.enable = true;
}
