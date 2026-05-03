# Gaming-specific GPU extensions -- system-level only.
# User tools (vulkan-tools) and session variables are managed
# by Home Manager (home/modules/gaming/gpu.nix).
{ ... }:

{
  hardware.graphics.enable32Bit = true;
}
