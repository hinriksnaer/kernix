# Bitwarden CLI -- available on all hosts.
# rbw provides agent-based session management (no manual BW_SESSION export).
# Desktop app and SSH agent are in home/apps/bitwarden.nix (desktop/laptop only).
{pkgs, ...}: {
  home.packages = with pkgs; [
    bitwarden-cli # official CLI (bw)
    rbw # agent-based CLI (rbw unlock, rbw get, etc.)
  ];
}
