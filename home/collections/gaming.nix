# Gaming collection -- overlays, Proton management, GPU diagnostics.
# Import this in profiles that need gaming support (e.g. desktop).
{ ... }:

{
  imports = [
    ../modules/gaming/tools.nix
    ../modules/gaming/gpu
  ];
}
