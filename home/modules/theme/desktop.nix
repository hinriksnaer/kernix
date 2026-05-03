# Desktop theme -- GUI pickers, wallpaper management, and desktop hook registrations.
# These pull in heavy dependencies (rofi, swaybg) and reference options from the
# emulators module (kernix.terminal), so they are only imported by desktop/laptop
# profiles via collections/desktop.nix.
{
  pkgs,
  config,
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
  home.packages = [
    # Wallpaper picker (rofi grid)
    (mkScript "kernix-rofi-wallpaper-select" (with pkgs; [rofi swaybg findutils coreutils]))

    # Desktop theme scripts
    (mkScript "kernix-rofi-theme-select" (with pkgs; [rofi coreutils gnused libnotify]))
    (mkScript "kernix-wallpaper-set" (with pkgs; [swaybg coreutils findutils procps]))
    (mkScript "kernix-wallpaper-next" (with pkgs; [swaybg coreutils findutils procps libnotify]))
  ];

  # ── Desktop hook registrations ──
  # These hooks require the emulators module (kernix.terminal) and
  # desktop apps that are only available on desktop/laptop profiles.
  xdg.configFile = {
    "kernix/theme-hooks.d/20-waybar".text = ''
      source=waybar.css
      target=~/.config/waybar/theme.css
      reload=pkill -SIGUSR2 -f waybar
    '';
    "kernix/theme-hooks.d/21-terminal".text = let
      t = config.kernix.terminal.themeHook;
    in ''
      source=${t.source}
      target=${t.target}
      ${
        if t.reload != ""
        then "reload=${t.reload}"
        else ""
      }
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
}
