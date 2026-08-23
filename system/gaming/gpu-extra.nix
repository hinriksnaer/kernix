# Gaming-specific GPU extensions -- system-level only.
# User tools (vulkan-tools) and session variables are managed
# by Home Manager (home/gaming/gpu/).
{
  config,
  lib,
  ...
}:
lib.mkIf config.kernix.gaming.enable {
  hardware.graphics.enable32Bit = true;
}
