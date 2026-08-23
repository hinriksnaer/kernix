# Bitwarden -- desktop app and SSH agent.
# CLI (bw) is in home/terminal/bitwarden.nix for all hosts.
{
  pkgs,
  host,
  lib,
  ...
}:
lib.mkIf host.apps.enable {
  home.packages = with pkgs; [
    bitwarden-desktop
  ];

  # Bitwarden desktop exposes an SSH agent via Unix socket.
  home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";

  # Auto-launch Bitwarden desktop with Hyprland so the agent is available.
  wayland.windowManager.hyprland.settings.exec-once = [
    "bitwarden"
  ];
}
