# Bitwarden CLI -- available on all hosts.
# Desktop app and SSH agent are in home/apps/bitwarden.nix (desktop/laptop only).
{pkgs, ...}: {
  home.packages = [pkgs.bitwarden-cli];
}
