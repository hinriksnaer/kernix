# Desktop -- Hyprland desktop environment.
{...}: {
  imports = [
    ./monitors.nix
    ./hyprland.nix
    ./emulators
    ./mako.nix
    ./waybar
    ./rofi.nix
    ./hyprlock.nix
    ./session.nix
    ./audio.nix
    ./power-menu.nix
    ./hardware-tools.nix
    ../theme/desktop.nix
  ];
}
