# Container profile -- Kubernetes/OpenShift pods running as root.
{
  pkgs,
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

  home.packages = [cli.kernix-hm-switch];
}
