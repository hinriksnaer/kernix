# OpenCode -- AI coding assistant with Vertex AI support.
# Installs the package and sets up theme integration.
# Vertex AI auth is handled by vertex-auth.nix module.
{
  pkgs,
  config,
  settings,
  ...
}: let
  defaultTheme = settings.defaultTheme;
  kernixPath = "${config.home.homeDirectory}/.local/share/kernix";
  ocDir = "${config.home.homeDirectory}/.config/opencode";
in {
  home.packages = [pkgs.opencode];

  # Symlink per-theme opencode.json files into ~/.config/opencode/themes/
  # and create initial tui.json with the default theme.
  # Theme switching is handled by kernix-theme-apply (config-rewrite hook on tui.json).
  home.activation.opencodeConfig = config.lib.dag.entryAfter ["linkGeneration"] ''
    mkdir -p "${ocDir}/themes"

    # Symlink each theme's opencode.json
    for theme_dir in "${kernixPath}/themes"/*/; do
      theme=$(basename "$theme_dir")
      if [ -f "$theme_dir/opencode.json" ]; then
        ln -sf "$theme_dir/opencode.json" "${ocDir}/themes/$theme.json"
      fi
    done

    # Create tui.json with default theme if it doesn't exist
    if [ ! -f "${ocDir}/tui.json" ]; then
      echo '{"$schema":"https://opencode.ai/tui.json","theme":"${defaultTheme}"}' > "${ocDir}/tui.json"
    fi
  '';
}
