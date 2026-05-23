# Bitwarden -- desktop app and SSH agent.
# CLI (bw) is in home/terminal/bitwarden.nix for all hosts.
{pkgs, ...}: {
  home.packages = with pkgs; [
    bitwarden-desktop
  ];
}
