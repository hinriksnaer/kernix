# Kernix theme engine -- unified theme switching for all apps.
# Provides core scripts, hook registrations, and theme data deployment.
# Each app opts into theming via a hook in ~/.config/kernix/theme-hooks.d/.
# The engine applies what it can and skips the rest.
{
  pkgs,
  lib,
  config,
  settings,
  ...
}: let
  kernixPath = "${config.home.homeDirectory}/.local/share/kernix";
  scripts = ./scripts;

  mkScript = name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = ''
        export KERNIX_PATH="${kernixPath}"
        ${builtins.readFile "${scripts}/${name}.sh"}
      '';
    };
in {
  # ── Core engine scripts ──
  home.packages = [
    (mkScript "kernix-theme-set" (with pkgs; [coreutils gnused] ++ lib.optionals stdenv.isLinux [libnotify]))
    (pkgs.writeShellApplication {
      name = "kernix-theme-apply";
      runtimeInputs = with pkgs; [coreutils gnused findutils];
      excludeShellChecks = ["SC2129"];
      text = ''
        export KERNIX_PATH="${kernixPath}"
        ${builtins.readFile "${scripts}/kernix-theme-apply.sh"}
      '';
    })
    (mkScript "kernix-theme-current" (with pkgs; [coreutils]))
    (mkScript "kernix-theme-list" (with pkgs; [coreutils]))
    (mkScript "kernix-theme-next" [])
    (mkScript "kernix-theme-prev" [])
    (mkScript "kernix-theme-refresh" [])
    (mkScript "kernix-theme" (with pkgs; [coreutils gnused fzf]))

    # Custom apply scripts for apps with complex logic
    (mkScript "kernix-theme-apply-neovim" (with pkgs; [neovim coreutils]))
    (mkScript "kernix-theme-apply-yazi" (with pkgs; [coreutils gnugrep]))
  ];

  home.sessionVariables.KERNIX_PATH = kernixPath;

  # ── Theme data deployment ──
  # Single directory symlink to the nix store. The theme engine only
  # reads from this path, so immutable nix store is safe.
  xdg.dataFile."kernix/themes".source = ../../../themes;

  # ── Hook registrations (terminal apps) ──
  # Desktop hooks (waybar, terminal emulator, rofi, hyprlock, mako, hyprland)
  # live in desktop.nix since they require the emulators module.
  xdg.configFile = {
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
  };

  # ── Default theme seeding ──
  home.activation.kernixConfig = config.lib.dag.entryAfter ["linkGeneration"] ''
    mkdir -p "$HOME/.config/kernix"
    if [ ! -f "$HOME/.config/kernix/current-theme" ]; then
      echo "${settings.defaultTheme}" > "$HOME/.config/kernix/current-theme"
    fi
  '';
}
