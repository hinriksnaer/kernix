# Rofi application launcher (Wayland).
# Theme loaded at runtime via @theme directive (swapped by kernix-theme-set).
{
  pkgs,
  config,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;

    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus";
      display-drun = "Applications";
      display-run = "Run";
      display-window = "Windows";
      display-ssh = "SSH";
      drun-display-format = "{name}";
      modi = "drun,run,window";
      sidebar-mode = true;
      hover-select = true;
      me-select-entry = "";
      me-accept-entry = "MousePrimary";
      show-match = false;
    };

    # Theme file swapped at runtime by kernix-theme-apply
    theme = "${config.home.homeDirectory}/.config/rofi/theme.rasi";
  };

  # Create empty stub so rofi doesn't error before first theme switch
  home.activation.rofiThemeStub = config.lib.dag.entryAfter ["linkGeneration"] ''
    [ -e "$HOME/.config/rofi/theme.rasi" ] || touch "$HOME/.config/rofi/theme.rasi"
  '';
}
