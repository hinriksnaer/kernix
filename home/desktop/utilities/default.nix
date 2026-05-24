# Desktop utilities -- audio control, hardware tools.
# These are compositor-agnostic helper scripts bound to keybinds.
{...}: {
  imports = [
    ./audio.nix
    ./hardware-tools.nix
  ];
}
