# Printing -- system-level only.
# Enables CUPS with driverless IPP printing and Avahi for
# network printer discovery (Canon MF650C @ 192.168.1.212).
{
  config,
  lib,
  ...
}:
lib.mkIf config.kernix.hardware.enable {
  services.printing = {
    enable = true;
    browsing = true;
    defaultShared = false;
  };

  # Avahi for automatic network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  users.users.${config.kernix.username}.extraGroups = ["lp"];
}
