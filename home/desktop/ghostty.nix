# Ghostty terminal emulator.
{
  config,
  host,
  lib,
  ...
}:
lib.mkIf (host.desktop.enable && host.terminal == "ghostty") {
  kernix.theme.hooks = ["ghostty"];

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = host.font.monospace;
      font-size = 16;
      font-style = "Regular";
      font-thicken = false;
      freetype-load-flags = "hinting,no-force-autohint,no-monochrome,no-autohint";
      adjust-cell-height = 2;
      window-padding-x = 14;
      window-padding-y = 14;
      gtk-single-instance = true;
      window-decoration = false;
      confirm-close-surface = false;
      cursor-style = "block";
      mouse-hide-while-typing = true;
      # Ghostty ships an `xterm-ghostty` terminfo entry that remote hosts do
      # not have (and /usr/share/terminfo is root-owned). With ssh-terminfo it
      # installs the entry into the remote's ~/.terminfo on first connect
      # (user-writable, no admin needed) and caches per host; ssh-env forwards
      # COLORTERM so truecolor is detected -- best effort, since that half
      # depends on the server's sshd AcceptEnv. Defaults are `no-ssh-env` and
      # `no-ssh-terminfo`, which is why a fresh server shows "unknown terminal".
      shell-integration-features = "cursor,no-sudo,title,ssh-env,ssh-terminfo,path";
      config-file = "${config.home.homeDirectory}/.config/ghostty/theme";
      keybind = [
        "ctrl+insert=copy_to_clipboard"
        "shift+insert=paste_from_clipboard"
      ];
    };
  };
}
