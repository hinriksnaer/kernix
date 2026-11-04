# Gaming -- overlays, Proton management, GPU diagnostics, couch mode.
{...}: {
  imports = [
    ./tools.nix
    ./battlenet.nix
    ./gpu
    ./couch.nix
  ];
}
