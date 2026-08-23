{lib, ...}: {
  options.kernix.hardware.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable hardware configuration (audio, bluetooth, GPU, networking, printing, boot).";
  };
}
