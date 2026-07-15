# Ghostty terminal emulator.
{config, ...}: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 16;
      font-style = "SemiBold";
      font-thicken = false;
      adjust-cell-height = 2;
      window-padding-x = 14;
      window-padding-y = 14;
      gtk-single-instance = true;
      window-decoration = false;
      confirm-close-surface = false;
      cursor-style = "block";
      mouse-hide-while-typing = true;
      config-file = "theme";
      keybind = [
        "ctrl+insert=copy_to_clipboard"
        "shift+insert=paste_from_clipboard"
      ];
    };
  };

  # ── Theme hook (21-terminal) ──
  xdg.configFile."kernix/theme-hooks.d/21-terminal".text = ''
    source=ghostty.conf
    target=~/.config/ghostty/theme
    reload=busctl --user call com.mitchellh.ghostty /com/mitchellh/ghostty org.gtk.Actions Activate sava{sv} reload-config 0 0
  '';

  # Create empty stub so ghostty doesn't error before first theme switch
  home.activation.terminalThemeStub = config.lib.dag.entryAfter ["linkGeneration"] ''
    [ -e "$HOME/.config/ghostty/theme" ] || touch "$HOME/.config/ghostty/theme"
  '';
}
