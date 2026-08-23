# macOS (nix-darwin) profile -- terminal tooling only.
# Applied as a darwin module via darwinConfigurations.macbook.
{
  pkgs,
  config,
  host,
  hostname,
  ...
}: let
  username = host.username;
  homeDir = config.home.homeDirectory;
  kernixRoot = "${homeDir}/kernix";
  cli = import ../../cli {
    inherit pkgs;
    hmProfile = "${username}@${hostname}";
    darwinHost = hostname;
  };
in {
  # CLI helpers: pull + rebuild
  home.packages = [
    cli.kernix-darwin-switch
    cli.kernix-hm-switch
  ];

  # Skip ownership check on Nix-managed zsh dirs (multi-user Nix on macOS)
  programs.zsh.completionInit = "autoload -Uz compinit && compinit -u";

  # Ghostty terminfo for SSH sessions (ghostty ships it in the app bundle)
  home.activation.ghosttyTerminfo = config.lib.dag.entryAfter ["linkGeneration"] ''
    if [ -d "/Applications/Ghostty.app/Contents/Resources/terminfo" ]; then
      mkdir -p "$HOME/.terminfo"
      cp -r /Applications/Ghostty.app/Contents/Resources/terminfo/* "$HOME/.terminfo/"
    fi
  '';

  # Auto-activate devshell when cd-ing into workspace/repos
  home.activation.setupWorkspaceDirenv = config.lib.dag.entryAfter ["linkGeneration"] ''
    mkdir -p "${homeDir}/workspace"
    envrc="${homeDir}/workspace/.envrc"
    if [ ! -f "$envrc" ] || ! grep -q "use flake ${kernixRoot}" "$envrc" 2>/dev/null; then
      cat > "$envrc" << 'ENVRC'
    use flake ${kernixRoot}

    # Activate venv after devshell (direnv doesn't run shellHook)
    if [ -f "$HELION_WORKSPACE/.venv/bin/activate" ]; then
      source "$HELION_WORKSPACE/.venv/bin/activate"
    fi
    ENVRC
    fi
    ${pkgs.direnv}/bin/direnv allow "$envrc" 2>/dev/null || true
  '';
}
