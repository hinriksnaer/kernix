# GPU driver configuration, dispatched by kernix.gpu option.
# Vendor-specific config lives in nvidia.nix, intel.nix, amd.nix.
# This file handles imports and common config shared across all GPUs.
{
  config,
  lib,
  ...
}: let
  cfg = config.kernix;
  hasGpu = cfg.gpu != "none";
  hasNvidia = cfg.gpu == "nvidia";
  hasIntel = cfg.gpu == "intel";
  hasAmd = cfg.gpu == "amd";
in {
  imports = [
    ./nvidia.nix
    ./intel.nix
    ./amd.nix
  ];

  config = lib.mkIf (cfg.hardware.enable && hasGpu) {
    # ── Common (all GPUs) ──
    users.users.${cfg.username}.extraGroups =
      ["video"] ++ lib.optional (hasIntel || hasAmd) "render";

    # Suppress nvidia-container-toolkit assertion on non-nvidia hosts
    hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion = !hasNvidia;
  };
}
