# Sesh -- smart tmux session manager.
# Lives under tmux/plugins because the tmux keybinds invoke it
# (prefix+Space, see ../keybinds.conf). Replaces the old
# kernix-sessionizer script.
{pkgs, ...}: {
  home.packages = [pkgs.sesh];

  # Window layouts + project sources
  xdg.configFile."sesh/sesh.toml".source = ./sesh.toml;
}
