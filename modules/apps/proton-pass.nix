# Proton Pass -- system-level only.
# User tools (pass-cli, pass-ssh-setup, proton-pass app) are managed
# by Home Manager (home/modules/apps/proton-pass.nix).
{ ... }:

{
  # gnome-keyring for general secret storage (other apps, not pass-cli)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Disable GCR SSH agent -- Proton Pass manages SSH keys instead.
  # Without this, GCR claims SSH_AUTH_SOCK and SSH never reaches Proton Pass.
  systemd.user.sockets.gcr-ssh-agent.enable = false;
}
