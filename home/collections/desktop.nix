# Desktop collection -- Hyprland desktop environment.
# Import this in desktop/laptop profiles alongside terminal.nix.
{...}: {
  imports = [
    ../modules/desktop/monitors.nix
    ../modules/desktop/hyprland.nix
    ../modules/desktop/kitty.nix
    ../modules/desktop/mako.nix
    ../modules/desktop/waybar
    ../modules/desktop/rofi.nix
    ../modules/desktop/hyprlock.nix
    ../modules/desktop/session.nix
    ../modules/desktop/audio.nix
    ../modules/desktop/power-menu.nix
    ../modules/desktop/hardware-tools.nix
    ../modules/theme/desktop.nix
  ];
}
