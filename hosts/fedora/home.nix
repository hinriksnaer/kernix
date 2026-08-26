# Fedora CSB -- non-NixOS desktop host.
# Provides: genericLinux integration, GPU driver setup, Hyprland + Wayland
# session via Nix (unavailable in Fedora repos without third-party COPR),
# XDG portals, TTY1 session start, and CLI helper.
{
  pkgs,
  host,
  hostname,
  lib,
  ...
}: let
  username = host.username;
  cli = import ../../cli {
    inherit pkgs;
    hmProfile = "${username}@${hostname}";
    systemManagerConfig = "fedora";
  };
in {
  # ── Non-NixOS Linux integration ──
  targets.genericLinux.enable = true;

  # GPU: build Mesa driver env from nixpkgs, symlink to /run/opengl-driver.
  # First-time setup requires: sudo non-nixos-gpu-setup
  targets.genericLinux.gpu.enable = true;

  # ── Hyprland + Wayland session ──
  home.packages = with pkgs; [
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xwayland
    cli.kernix-fedora-switch
  ];

  # Start Hyprland on TTY1 login.
  # mkOrder 99 fires before the existing UWSM block (mkOrder 100) in
  # home/desktop/hyprland/default.nix. The `exec` replaces the shell so
  # the UWSM block never runs.
  programs.zsh.initContent = lib.mkOrder 99 ''
    if [[ "$(tty)" == "/dev/tty1" && -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]]; then
        exec Hyprland
    fi
  '';
}
