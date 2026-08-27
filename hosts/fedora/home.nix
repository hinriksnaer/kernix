# Fedora CSB -- non-NixOS desktop host.
# Provides: genericLinux integration, GPU driver setup, Hyprland + Wayland
# session via Nix (unavailable in Fedora repos without third-party COPR),
# XDG portals, and CLI helper.
{
  pkgs,
  host,
  hostname,
  ...
}: let
  username = host.username;
  cli = import ../../cli {
    inherit pkgs;
    hostType = "hm";
    hmProfile = "${username}@${hostname}";
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
    cli.kernix
  ];
}
