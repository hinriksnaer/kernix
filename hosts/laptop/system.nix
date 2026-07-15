{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../system/core
    ../../system/desktop
    ../../system/hardware
    ../../system/apps
    ./power.nix
  ];
}
