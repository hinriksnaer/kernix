# Kitty terminal emulator.
# Activated when settings.terminal == "kitty".
{
  config,
  lib,
  settings,
  ...
}:
lib.mkIf (settings.terminal == "kitty") {
  kernix.terminal = {
    command = "kitty";
    execFlag = "-e";
    windowClass = "kitty";
    themeHook = {
      source = "kitty.conf";
      target = "~/.config/kitty/theme.conf";
      reload = "pkill -SIGUSR1 -f kitty";
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "CaskaydiaMono Nerd Font";
      size = 9.0;
    };
    settings = {
      window_padding_width = 14;
      window_padding_height = 14;
      hide_window_decorations = "yes";
      show_window_resize_notification = "no";
      confirm_os_window_close = 0;
      cursor_shape = "block";
      enable_audio_bell = "no";
      single_instance = "yes";
      allow_remote_control = "yes";
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
    };
    keybindings = {
      "ctrl+insert" = "copy_to_clipboard";
      "shift+insert" = "paste_from_clipboard";
    };
    extraConfig = ''
      include theme.conf
    '';
  };

  home.activation.terminalThemeStub = config.lib.dag.entryAfter ["linkGeneration"] ''
    [ -e "$HOME/.config/kitty/theme.conf" ] || touch "$HOME/.config/kitty/theme.conf"
  '';
}
