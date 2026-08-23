{config, ...}: {
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = config.kernix.hardware.wifi.powersave;
  users.users.${config.kernix.username}.extraGroups = ["networkmanager"];
}
