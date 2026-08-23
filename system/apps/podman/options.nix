{lib, ...}: {
  options.kernix.apps.podman.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable Podman container runtime (requires apps.enable).";
  };
}
