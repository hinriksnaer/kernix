# Hyprland -- system-level only.
# User configuration (keybinds, appearance, env vars, packages) is managed
# by Home Manager (home/modules/desktop/hyprland.nix).
{pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };
}
