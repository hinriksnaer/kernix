{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/core.nix
    ../../roles/desktop.nix
    ../../roles/hardware.nix
    ../../roles/apps.nix
  ];

  hawker.username = config.hawker.hosts.laptop.username;
  hawker.gpu = config.hawker.hosts.laptop.gpu;

  networking.hostName = "hawker-laptop";
}
