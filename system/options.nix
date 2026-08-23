# Full kernix option schema -- aggregates all feature options.
# Import this to get every kernix.* option with defaults.
{...}: {
  imports = [
    ../lib/kernix-options.nix
    ./desktop/options.nix
    ./desktop/hyprland/options.nix
    ./gaming/options.nix
    ./gaming/steam/options.nix
    ./gaming/sunshine/options.nix
    ./gaming/couch/options.nix
    ./apps/options.nix
    ./apps/podman/options.nix
    ./hardware/bluetooth/options.nix
    ./hardware/networking/options.nix
  ];
}
