# macOS (nix-darwin) profile -- terminal tooling only.
# Applied as a darwin module via darwinConfigurations.macbook.
{
  pkgs,
  config,
  settings,
  hostname,
  ...
}: let
  username = settings.hosts.${hostname}.username;
  homeDir = "/Users/${username}";
  kernixRoot = "${homeDir}/kernix";
  cli = import ../../cli {
    inherit pkgs;
    hmProfile = "${username}@${hostname}";
    darwinHost = hostname;
  };
in {
  imports = [
    ../collections/terminal.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  # CLI helpers: pull + rebuild
  home.packages = [
    cli.kernix-darwin-switch
    cli.kernix-hm-switch
  ];

  # Auto-activate devshell when cd-ing into workspace/repos
  home.activation.setupDirenv = config.lib.dag.entryAfter ["linkGeneration"] ''
    mkdir -p "${homeDir}/workspace"
    envrc="${homeDir}/workspace/.envrc"
    if [ ! -f "$envrc" ] || ! grep -q "use flake ${kernixRoot}" "$envrc" 2>/dev/null; then
      echo "use flake ${kernixRoot}" > "$envrc"
    fi
    ${pkgs.direnv}/bin/direnv allow "$envrc" 2>/dev/null || true
  '';
}
