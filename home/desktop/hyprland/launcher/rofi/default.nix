# Rofi application launcher -- Wayland-native.
# Theme loaded at runtime via @theme directive (swapped by kernix-theme-set).
# Provides: launcher commands, audio/power/theme/wallpaper picker scripts.
{
  pkgs,
  config,
  ...
}: {
  kernix.theme.hooks = ["rofi"];

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

  # ── Rofi-specific scripts ──
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "rofi-audio-select";
      runtimeInputs = [rofi wireplumber libnotify gawk];
      text = builtins.readFile ./scripts/rofi-audio-select.sh;
    })
    (writeShellApplication {
      name = "power-menu";
      runtimeInputs = [rofi systemd];
      text = builtins.readFile ./scripts/power-menu.sh;
      excludeShellChecks = ["SC2029" "SC2016"];
    })
    (writeShellApplication {
      name = "kernix-rofi-theme-select";
      runtimeInputs = [rofi coreutils gnused libnotify];
      text = ''
        export KERNIX_PATH="''${KERNIX_PATH:-$HOME/.local/share/kernix}"
        ${builtins.readFile ./scripts/kernix-rofi-theme-select.sh}
      '';
    })
    (writeShellApplication {
      name = "kernix-rofi-wallpaper-select";
      runtimeInputs = [rofi swaybg findutils coreutils];
      text = ''
        export KERNIX_PATH="''${KERNIX_PATH:-$HOME/.local/share/kernix}"
        ${builtins.readFile ./scripts/kernix-rofi-wallpaper-select.sh}
      '';
    })
  ];
}
