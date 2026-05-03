# Kernix theme engine -- unified theme switching for all apps.
# Provides core scripts, hook registrations, and theme data deployment.
# Each app opts into theming via a hook in ~/.config/kernix/theme-hooks.d/.
# The engine applies what it can and skips the rest.
{ pkgs, config, settings, ... }:

let
  kernixPath = "${config.home.homeDirectory}/.local/share/kernix";
  scripts = ./scripts;

  mkScript = name: runtimeInputs: pkgs.writeShellApplication {
    inherit name runtimeInputs;
    text = ''
      export KERNIX_PATH="${kernixPath}"
      ${builtins.readFile "${scripts}/${name}.sh"}
    '';
  };
in
{
  # ── Core engine scripts ──
  home.packages = [
    (mkScript "kernix-theme-set" (with pkgs; [ coreutils gnused libnotify ]))
    (pkgs.writeShellApplication {
      name = "kernix-theme-apply";
      runtimeInputs = with pkgs; [ coreutils gnused findutils ];
      excludeShellChecks = [ "SC2129" ];
      text = ''
        export KERNIX_PATH="${kernixPath}"
        ${builtins.readFile "${scripts}/kernix-theme-apply.sh"}
      '';
    })
    (mkScript "kernix-theme-current" (with pkgs; [ coreutils ]))
    (mkScript "kernix-theme-list" (with pkgs; [ coreutils ]))
    (mkScript "kernix-theme-next" [])
    (mkScript "kernix-theme-prev" [])
    (mkScript "kernix-theme-refresh" [])
    (mkScript "kernix-theme" (with pkgs; [ coreutils gnused fzf ]))

    # Custom apply scripts for apps with complex logic
    (mkScript "kernix-theme-apply-neovim" (with pkgs; [ neovim coreutils ]))
    (mkScript "kernix-theme-apply-yazi" (with pkgs; [ coreutils gnugrep ]))
  ];

  home.sessionVariables.KERNIX_PATH = kernixPath;

  # ── Theme data deployment ──
  # Single directory symlink to the nix store. The theme engine only
  # reads from this path, so immutable nix store is safe.
  xdg.dataFile."kernix/themes".source = ../../../themes;

  # ── Hook registrations ──
  # All apps register here. The engine skips hooks at runtime when
  # the source file or target directory doesn't exist.
  xdg.configFile = {
    # Terminal apps
    "kernix/theme-hooks.d/10-btop".text = ''
      source=btop.theme
      target=~/.config/btop/themes/active.theme
      reload=pkill -SIGUSR2 btop
    '';
    "kernix/theme-hooks.d/11-neovim".text = ''
      type=script
      script=kernix-theme-apply-neovim
      source=neovim.lua
    '';
    "kernix/theme-hooks.d/12-yazi".text = ''
      type=script
      script=kernix-theme-apply-yazi
    '';
    "kernix/theme-hooks.d/13-opencode".text = ''
      type=config-rewrite
      target=~/.config/opencode/tui.json
      key=theme
    '';

    # Desktop apps
    "kernix/theme-hooks.d/20-waybar".text = ''
      source=waybar.css
      target=~/.config/waybar/theme.css
      reload=pkill -SIGUSR2 -f waybar
    '';
    "kernix/theme-hooks.d/21-kitty".text = ''
      source=kitty.conf
      target=~/.config/kitty/theme.conf
      reload=pkill -SIGUSR1 -f kitty
    '';
    "kernix/theme-hooks.d/22-rofi".text = ''
      source=rofi.rasi
      target=~/.config/rofi/theme.rasi
    '';
    "kernix/theme-hooks.d/23-hyprlock".text = ''
      source=hyprlock.conf
      target=~/.config/hypr/hyprlock-theme.conf
    '';
    "kernix/theme-hooks.d/24-mako".text = ''
      source=mako.ini
      target=~/.config/mako/theme.conf
      reload=pkill -f mako; sleep 0.3; setsid mako >/dev/null 2>&1 &
    '';
    "kernix/theme-hooks.d/25-hyprland".text = ''
      type=hyprland
      reload=hyprctl reload
    '';
  };

  # ── Default theme seeding ──
  home.activation.kernixConfig = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "$HOME/.config/kernix"
    if [ ! -f "$HOME/.config/kernix/current-theme" ]; then
      echo "${settings.defaultTheme}" > "$HOME/.config/kernix/current-theme"
    fi
  '';
}
