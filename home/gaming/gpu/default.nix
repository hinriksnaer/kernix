# GPU diagnostics and gaming-specific session variables.
# Vendor-specific config lives in nvidia.nix (others added as needed).
# System-level parts (hardware.graphics.enable32Bit) stay in
# system/gaming/gpu-extra.nix.
{pkgs, ...}: {
  imports = [
    ./nvidia.nix
  ];

  # ── Common (all GPUs) ──
  home.packages = with pkgs; [
    vulkan-tools
  ];
}
