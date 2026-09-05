# Desktop applications and utilities.
# Single-package apps that don't need NixOS-level configuration.
{
  pkgs,
  host,
  lib,
  ...
}:
lib.mkIf host.apps.enable {
  home.packages = with pkgs; [
    # Applications
    vesktop
    slack
    obsidian

    # Containers
    podman-compose

    # Screenshot
    grim
    slurp

    # Clipboard
    cliphist
    wl-clipboard
  ];
}
