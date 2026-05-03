{ pkgs, config, ... }:

{
  networking.networkmanager.enable = true;
  users.users.${config.kernix.username}.extraGroups = [ "networkmanager" ];
}
