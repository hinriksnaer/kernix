{config, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../system/core
    ../../system/desktop
    ../../system/hardware
    ../../system/apps
    ../../system/gaming
    ./fancontrol.nix
  ];

  kernix.username = config.kernix.hosts.desktop.username;
  kernix.gpu = config.kernix.hosts.desktop.gpu;

  networking.hostName = "kernix-desktop";
}
