# Gaming -- overlays, Proton management, GPU diagnostics, couch mode.
{...}: {
  imports = [
    ./tools.nix
    ./battlenet.nix
    ./tsm-desktop.nix
    ./gpu
    ./couch.nix
  ];
}
