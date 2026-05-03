{config, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../roles/core.nix
    ../../roles/desktop.nix
    ../../roles/hardware.nix
    ../../roles/apps.nix
  ];

  kernix.username = config.kernix.hosts.laptop.username;
  kernix.gpu = config.kernix.hosts.laptop.gpu;

  networking.hostName = "kernix-laptop";
}
