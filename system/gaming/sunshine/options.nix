{lib, ...}: {
  options.kernix.gaming.sunshine.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable Sunshine game streaming (requires gaming.enable).";
  };
}
