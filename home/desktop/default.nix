# Desktop -- Hyprland desktop environment.
# Sub-modules gate themselves via lib.mkIf host.desktop.enable.
{...}: {
  imports = [
    ./dolphin.nix
    ./fonts.nix
    ./hyprland
    ./ghostty.nix
    ./session.nix
    ./utilities
  ];
}
