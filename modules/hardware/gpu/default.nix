# GPU driver configuration, dispatched by kernix.gpu option.
# Vendor-specific config lives in nvidia.nix, intel.nix, amd.nix.
# This file handles imports and common config shared across all GPUs.
{ config, lib, ... }:

let
  cfg = config.kernix;
  hasNvidia = cfg.gpu == "nvidia";
  hasIntel  = cfg.gpu == "intel";
  hasAmd    = cfg.gpu == "amd";
in
{
  imports = [
    ./nvidia.nix
    ./intel.nix
    ./amd.nix
  ];

  # ── Common (all GPUs) ──
  users.users.${cfg.username}.extraGroups =
    [ "video" ] ++ lib.optional (hasIntel || hasAmd) "render";

  # Suppress nvidia-container-toolkit assertion on non-nvidia hosts
  hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion = !hasNvidia;
}
