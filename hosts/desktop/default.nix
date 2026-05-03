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

  hawker.username = config.hawker.hosts.desktop.username;
  hawker.gpu = config.hawker.hosts.desktop.gpu;

  networking.hostName = "hawker";
}
