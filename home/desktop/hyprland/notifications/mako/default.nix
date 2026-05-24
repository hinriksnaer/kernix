# Mako notification daemon.
# Theme colors loaded at runtime via include (swapped by kernix-theme-set).
{config, ...}: {
  services.mako = {
    enable = true;

    settings = {
      width = 420;
      height = 110;
      padding = 10;
      border-size = 2;
      border-radius = 8;
      font = "JetBrainsMono Nerd Font 11";

      anchor = "top-right";
      outer-margin = 20;

      default-timeout = 5000;
      ignore-timeout = 0;
      max-visible = 5;
      sort = "-time";

      max-icon-size = 48;
      group-by = "app-name";

      # Theme colors (symlinked by kernix-theme-apply)
      include = "~/.config/mako/theme.conf";
    };
  };

  # ── Theme hook (24-mako) ──
  xdg.configFile."kernix/theme-hooks.d/24-mako".text = ''
    source=mako.ini
    target=~/.config/mako/theme.conf
    reload=pkill -f mako; sleep 0.3; setsid mako >/dev/null 2>&1 &
  '';

  # Create empty stub so mako doesn't error before first theme switch
  home.activation.makoThemeStub = config.lib.dag.entryAfter ["linkGeneration"] ''
    [ -e "$HOME/.config/mako/theme.conf" ] || touch "$HOME/.config/mako/theme.conf"
  '';
}
