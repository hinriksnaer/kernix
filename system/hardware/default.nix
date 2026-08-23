{...}: {
  imports = [
    ./options.nix
    ./audio.nix
    ./bluetooth
    ./boot.nix
    ./gpu
    ./networking
    ./printing.nix
  ];
}
