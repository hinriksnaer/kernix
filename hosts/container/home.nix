# Container profile -- Kubernetes/OpenShift pods running as root.
# Apply with: nix run home-manager/master -- switch --flake ~/workspace/settings#root@container
{
  pkgs,
  config,
  settings,
  hostname,
  ...
}: let
  username = settings.hosts.${hostname}.username;
  homeDir = config.home.homeDirectory;
  kernixRoot = settings.hosts.${hostname}.kernixRoot or "${homeDir}/kernix";
  cli = import ../../cli {
    inherit pkgs;
    hmProfile = "${username}@${hostname}";
  };
in {
  imports = [
    ../../home/terminal
  ];

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
