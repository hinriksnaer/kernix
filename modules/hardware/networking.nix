{config, ...}: {
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  users.users.${config.kernix.username}.extraGroups = ["networkmanager"];
}
