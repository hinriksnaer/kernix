# Container profile -- the dev container and Kubernetes/OpenShift pods.
{
  pkgs,
  lib,
  config,
  host,
  hostname,
  ...
}: let
  username = host.username;
  homeDir = config.home.homeDirectory;
  kernixRoot =
    if host.kernixRoot != ""
    then host.kernixRoot
    else "${homeDir}/kernix";
  cli = import ../../cli {
    inherit pkgs;
    hostType = "hm";
    hmProfile = "${username}@${hostname}";
  };
in {
  # Terminal settings that oc exec doesn't propagate
  home.sessionVariables = {
    USER = username;
    TERM = "xterm-256color";
    COLORTERM = "truecolor";
    LANG = "C.UTF-8";
    KERNIX_ROOT = kernixRoot;
  };

  # oc exec starts a non-login shell that only sources .bashrc, not .profile.
  # Ensure Nix paths and session vars are loaded.
  programs.bash.initExtra = ''
    [ -f "${homeDir}/.nix-profile/etc/profile.d/nix.sh" ] && . "${homeDir}/.nix-profile/etc/profile.d/nix.sh"
    [ -f "${homeDir}/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "${homeDir}/.nix-profile/etc/profile.d/hm-session-vars.sh"
  '';

  # pkgs.nix belongs in the profile: after dropBootstrapProfile hands
  # ~/.nix-profile to Home Manager, /root/.nix-profile/bin/nix stops existing
  # (the profile ships kernix, not nix). `nix` still resolves through
  # /nix/var/nix/profiles/default/bin, but activation hooks that cached the
  # old path (setupDirenv -> direnv allow) fail without this.
  home.packages = [cli.kernix pkgs.nix];

  # No Bitwarden desktop app in a container, so the ssh agent is rbw's
  # built-in one (rbw-agent creates this socket on `rbw unlock`). Set it here
  # as well as in the zsh refresh block so non-interactive git (scripts,
  # agents) gets the agent too; the zsh block re-points it at a
  # rbw-<profile>/ socket when RBW_PROFILE is in use.
  home.sessionVariables.SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR:-$HOME/.run}/rbw/ssh-agent-socket";

  # The stock nixos/nix image ships ~/.nix-profile ->
  # /nix/var/nix/profiles/default, an OLD-style profile with a populated
  # manifest.nix (man-db, git-minimal, ...). Home Manager's installPackages
  # picks `nix-env -i` for old-style profiles and then installs into that same
  # profile, colliding with the image's packages:
  #   conflict for "/nix/store/...-man-db/bin/accessdb"
  # Drop the bootstrap link once so Home Manager owns its own profile.
  # Guarded, so it is a no-op on every subsequent activation; runs before
  # writeBoundary so linkGeneration/installPackages see the clean state.
  home.activation.dropBootstrapProfile = lib.hm.dag.entryBefore ["writeBoundary"] ''
    if [ -L "$HOME/.nix-profile" ] && [ "$(readlink "$HOME/.nix-profile")" = /nix/var/nix/profiles/default ]; then
      verboseEcho "Removing bootstrap ~/.nix-profile so Home Manager can own it"
      rm -f "$HOME/.nix-profile"
    fi
  '';
}
