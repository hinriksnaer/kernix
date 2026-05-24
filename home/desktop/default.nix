# Desktop -- Hyprland desktop environment.
{...}: {
  imports = [
    ./monitors.nix
    ./hyprland
    ./ghostty.nix
    ./session.nix
    ./utilities
  ];
}
