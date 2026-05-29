{config, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../system/core
    ../../system/desktop
    ../../system/hardware
    ../../system/apps
    ./power.nix
  ];

  kernix.username = config.kernix.hosts.laptop.username;
  kernix.gpu = config.kernix.hosts.laptop.gpu;

  networking.hostName = "kernix-laptop";
}
