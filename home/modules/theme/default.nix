# Hawker theme engine -- unified theme switching for all apps.
# Provides core scripts, hook registrations, and theme data deployment.
# Each app opts into theming via a hook in ~/.config/hawker/theme-hooks.d/.
# The engine applies what it can and skips the rest.
{ pkgs, config, settings, ... }:

let
  hawkerPath = "${config.home.homeDirectory}/.local/share/hawker";
  scripts = ./scripts;

  mkScript = name: runtimeInputs: pkgs.writeShellApplication {
    inherit name runtimeInputs;
    text = ''
      export HAWKER_PATH="${hawkerPath}"
      ${builtins.readFile "${scripts}/${name}.sh"}
    '';
  };
in
{
  # ── Core engine scripts ──
  home.packages = [
    (mkScript "hawker-theme-set" (with pkgs; [ coreutils gnused libnotify ]))
    (pkgs.writeShellApplication {
      name = "hawker-theme-apply";
      runtimeInputs = with pkgs; [ coreutils gnused findutils ];
      excludeShellChecks = [ "SC2129" ];
      text = ''
        export HAWKER_PATH="${hawkerPath}"
        ${builtins.readFile "${scripts}/hawker-theme-apply.sh"}
      '';
    })
    (mkScript "hawker-theme-current" (with pkgs; [ coreutils ]))
    (mkScript "hawker-theme-list" (with pkgs; [ coreutils ]))
    (mkScript "hawker-theme-next" [])
    (mkScript "hawker-theme-prev" [])
    (mkScript "hawker-theme-refresh" [])
    (mkScript "hawker-theme" (with pkgs; [ coreutils gnused fzf ]))

    # Custom apply scripts for apps with complex logic
    (mkScript "hawker-theme-apply-neovim" (with pkgs; [ neovim coreutils ]))
    (mkScript "hawker-theme-apply-yazi" (with pkgs; [ coreutils gnugrep ]))
  ];

  home.sessionVariables.HAWKER_PATH = hawkerPath;

  # ── Theme data deployment ──
  # Single directory symlink to the nix store. The theme engine only
  # reads from this path, so immutable nix store is safe.
  xdg.dataFile."hawker/themes".source = ../../../themes;

  # ── Hook registrations ──
  # All apps register here. The engine skips hooks at runtime when
  # the source file or target directory doesn't exist.
  xdg.configFile = {
    # Terminal apps
    "hawker/theme-hooks.d/10-btop".text = ''
      source=btop.theme
      target=~/.config/btop/themes/active.theme
      reload=pkill -SIGUSR2 btop
    '';
    "hawker/theme-hooks.d/11-neovim".text = ''
      type=script
      script=hawker-theme-apply-neovim
      source=neovim.lua
    '';
    "hawker/theme-hooks.d/12-yazi".text = ''
      type=script
      script=hawker-theme-apply-yazi
    '';
    "hawker/theme-hooks.d/13-opencode".text = ''
      type=config-rewrite
      target=~/.config/opencode/tui.json
      key=theme
    '';

    # Desktop apps
    "hawker/theme-hooks.d/20-waybar".text = ''
      source=waybar.css
      target=~/.config/waybar/theme.css
      reload=pkill -SIGUSR2 -f waybar
    '';
    "hawker/theme-hooks.d/21-kitty".text = ''
      source=kitty.conf
      target=~/.config/kitty/theme.conf
      reload=pkill -SIGUSR1 -f kitty
    '';
    "hawker/theme-hooks.d/22-rofi".text = ''
      source=rofi.rasi
      target=~/.config/rofi/theme.rasi
    '';
    "hawker/theme-hooks.d/23-hyprlock".text = ''
      source=hyprlock.conf
      target=~/.config/hypr/hyprlock-theme.conf
    '';
    "hawker/theme-hooks.d/24-mako".text = ''
      source=mako.ini
      target=~/.config/mako/theme.conf
      reload=pkill -f mako; sleep 0.3; setsid mako >/dev/null 2>&1 &
    '';
    "hawker/theme-hooks.d/25-hyprland".text = ''
      type=hyprland
      reload=hyprctl reload
    '';
  };

  # ── Default theme seeding ──
  home.activation.hawkerConfig = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "$HOME/.config/hawker"
    if [ ! -f "$HOME/.config/hawker/current-theme" ]; then
      echo "${settings.defaultTheme}" > "$HOME/.config/hawker/current-theme"
    fi
  '';
}
