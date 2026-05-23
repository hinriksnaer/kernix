# Desktop applications and utilities.
# Single-package apps that don't need NixOS-level configuration.
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Applications
    discord
    slack
    obsidian

    # File manager
    thunar

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
