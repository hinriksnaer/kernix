# Proton Pass -- password manager and SSH agent.
# System-level parts (gnome-keyring, PAM, systemd socket) stay in
# modules/apps/proton-pass.nix.
{ pkgs, config, ... }:

let
  agentSocket = "/home/${config.home.username}/.ssh/proton-pass-agent.sock";

  # Wrap pass-cli to work around NixOS kernel keyring group permissions bug.
  # NixOS creates the session keyring with gid 65534 (nogroup) instead of the
  # user's primary group, causing EACCES when pass-cli tries to store keys.
  # `keyctl new_session` replaces the current process's session keyring in-place
  # (unlike `keyctl session -` which execs into a new one), so the keyring persists
  # across all pass-cli invocations within the same shell session.
  # Upstream: https://github.com/NixOS/nixpkgs/issues/497155
  pass-cli-wrapped = pkgs.writeShellApplication {
    name = "pass-cli";
    runtimeInputs = [ pkgs.keyutils pkgs.proton-pass-cli ];
    text = ''
      keyctl new_session >/dev/null 2>&1 || true
      exec pass-cli "$@"
    '';
  };

  # Helper to check and set up the Proton Pass SSH agent connection.
  pass-ssh-setup = pkgs.writeShellApplication {
    name = "pass-ssh-setup";
    runtimeInputs = [ pkgs.openssh ];
    text = ''
      SOCK="${agentSocket}"

      echo "SSH_AUTH_SOCK=$SOCK"

      if [ ! -S "$SOCK" ]; then
        echo "Socket missing. Start Proton Pass desktop app to create it."
        exit 1
      fi

      if SSH_AUTH_SOCK="$SOCK" ssh-add -l >/dev/null 2>&1; then
        echo "Agent OK. Keys:"
        SSH_AUTH_SOCK="$SOCK" ssh-add -l
      else
        echo "Socket exists but agent not responding."
        echo "Try restarting Proton Pass, or remove stale socket:"
        echo "  rm $SOCK"
        exit 1
      fi
    '';
  };
in
{
  home.packages = [
    pass-cli-wrapped
    pass-ssh-setup
    pkgs.proton-pass     # Desktop app (unlocks shared vaults)
    pkgs.keyutils        # keyctl for Linux kernel keyring
  ];
}
