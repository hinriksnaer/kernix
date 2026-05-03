# GPU diagnostics and gaming-specific session variables.
# System-level parts (hardware.graphics.enable32Bit) stay in
# modules/gaming/gpu-extra.nix.
{ lib, pkgs, settings, hostname, ... }:

let
  hasNvidia = (settings.hosts.${hostname}.gpu or "none") == "nvidia";
in
{
  home.packages = with pkgs; [
    vulkan-tools
  ];

  # G-Sync / VRR (nvidia only)
  home.sessionVariables = lib.optionalAttrs hasNvidia {
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
  };
}
