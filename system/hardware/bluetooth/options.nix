{lib, ...}: {
  options.kernix.hardware.bluetooth.powerOnBoot = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Power on Bluetooth adapter at boot.";
  };
}
