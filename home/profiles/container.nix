# Container profile -- Kubernetes/OpenShift pods running as root.
# Apply with: nix run home-manager/master -- switch --flake ~/kernix#root@container
{
  pkgs,
  config,
  settings,
  hostname,
  ...
}: let
  username = settings.hosts.${hostname}.username;
  homeDir =
    if username == "root"
    then "/root"
    else "/home/${username}";
  kernixRoot = "${homeDir}/kernix";
  workspaceDir = "${homeDir}/workspace";
  cli = import ../../cli {
    inherit pkgs;
    hmProfile = "${username}@${hostname}";
  };
in {
  imports = [
    ../collections/terminal.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # oc exec starts a non-login shell that only sources .bashrc, not .profile.
  # Ensure Nix paths and USER are available in all interactive bash sessions.
  programs.bash.initExtra = ''
    export USER="${username}"
    [ -f "${homeDir}/.nix-profile/etc/profile.d/nix.sh" ] && . "${homeDir}/.nix-profile/etc/profile.d/nix.sh"
    [ -f "${homeDir}/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "${homeDir}/.nix-profile/etc/profile.d/hm-session-vars.sh"
  '';

  home.packages = [cli.kernix-hm-switch];

  # Auto-activate devshell when cd-ing into workspace
  home.activation.setupDirenv = config.lib.dag.entryAfter ["linkGeneration"] ''
    mkdir -p "${workspaceDir}"
    envrc="${workspaceDir}/.envrc"
    if [ ! -f "$envrc" ] || ! grep -q "use flake ${kernixRoot}" "$envrc" 2>/dev/null; then
      echo "use flake ${kernixRoot}" > "$envrc"
    fi
    ${pkgs.direnv}/bin/direnv allow "$envrc" 2>/dev/null || true
  '';
}
