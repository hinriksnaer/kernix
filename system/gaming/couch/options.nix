{lib, ...}: {
  options.kernix.gaming.couch.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable couch gaming session on TTY3 (requires gaming.enable).";
  };
}
