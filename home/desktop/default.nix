# Desktop -- Hyprland desktop environment.
{...}: {
  imports = [
    ./dolphin.nix
    ./monitors.nix
    ./hyprland
    ./ghostty.nix
    ./session.nix
    ./utilities
  ];
}
