# Ghostty terminal emulator.
# Activated when settings.terminal == "ghostty".
{
  config,
  lib,
  settings,
  ...
}:
lib.mkIf (settings.terminal == "ghostty") {
  kernix.terminal = {
    command = "ghostty";
    execFlag = "-e";
    windowClass = "com.mitchellh.ghostty";
    themeHook = {
      source = "ghostty.conf";
      target = "~/.config/ghostty/theme";
      reload = "busctl --user call com.mitchellh.ghostty /com/mitchellh/ghostty org.gtk.Actions Activate sava{sv} reload-config 0 0";
    };
  };

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = "CaskaydiaMono Nerd Font";
      font-size = 12;
      window-padding-x = 14;
      window-padding-y = 14;
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

  home.activation.terminalThemeStub = config.lib.dag.entryAfter ["linkGeneration"] ''
    [ -e "$HOME/.config/ghostty/theme" ] || touch "$HOME/.config/ghostty/theme"
  '';
}
