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
