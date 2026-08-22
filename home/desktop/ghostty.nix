# Ghostty terminal emulator.
{
  config,
  settings,
  ...
}: {
  kernix.theme.hooks = ["terminal"];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = settings.font.monospace;
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
      config-file = "${config.home.homeDirectory}/.config/ghostty/theme";
      keybind = [
        "ctrl+insert=copy_to_clipboard"
        "shift+insert=paste_from_clipboard"
      ];
    };
  };
}
