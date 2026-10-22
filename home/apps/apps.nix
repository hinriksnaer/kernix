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
    # VS Code -- FHS build so marketplace extensions work. openssh is baked
    # into the chroot: the host's /usr is not visible inside it, so Remote-SSH
    # can't find `ssh` otherwise.
    (vscode-fhsWithPackages (ps: [ps.openssh]))
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
