# Herdr -- agent multiplexer, alternative to tmux.
# Installs the package, deploys config.toml, and sets up theme integration.
{
  pkgs,
  config,
  ...
}: let
  themeLib = import ../../../lib/theme.nix {inherit pkgs config;};
  inherit (themeLib) kernixPath;
in {
  kernix.theme.hooks = ["herdr"];

  home.packages = [
    pkgs.herdr

    # Theme apply script (called by kernix-theme-apply hook engine)
    (pkgs.writeShellApplication {
      name = "kernix-theme-apply-herdr";
      runtimeInputs = with pkgs; [coreutils gnused];
      text = ''
        export KERNIX_PATH="${kernixPath}"
        ${builtins.readFile ../../theme/scripts/kernix-theme-apply-herdr.sh}
      '';
    })
  ];

  xdg.configFile."herdr/config.toml".source = ./config.toml;

  # Install agent integrations on activation (OpenCode + Claude Code).
  home.activation.herdrIntegrations = config.lib.dag.entryAfter ["linkGeneration"] ''
    if command -v herdr >/dev/null 2>&1; then
      if [ -d "$HOME/.config/opencode" ]; then
        herdr integration install opencode 2>/dev/null || true
      fi
      if [ -d "$HOME/.claude" ]; then
        herdr integration install claude 2>/dev/null || true
      fi
    fi
  '';
}
