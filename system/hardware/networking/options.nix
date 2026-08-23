{lib, ...}: {
  options.kernix.hardware.wifi.powersave = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable WiFi power saving (better battery, worse latency).";
  };
}
