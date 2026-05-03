{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/core.nix
    ../../roles/desktop.nix
    ../../roles/hardware.nix
    ../../roles/apps.nix
    ../../roles/gaming.nix
    ../../modules/hardware/fancontrol.nix
  ];

  kernix.username = config.kernix.hosts.desktop.username;
  kernix.gpu = config.kernix.hosts.desktop.gpu;

  networking.hostName = "kernix-desktop";
}
