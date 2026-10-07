# Herdr -- agent multiplexer, alternative to tmux.
# Installs the package, deploys config.toml, and sets up theme integration.
{
  pkgs,
  config,
  ...
}: {
  kernix.theme.hooks = ["herdr"];

  home.packages = [pkgs.herdr];

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
