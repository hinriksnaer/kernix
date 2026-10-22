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
    # VS Code lives in ./vscode.nix (FHS vs plain depends on the host).
    vesktop
    slack
    obsidian
    spotify

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
