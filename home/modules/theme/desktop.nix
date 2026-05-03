# Desktop theme scripts -- GUI pickers and wallpaper management.
# These pull in heavy dependencies (rofi, swaybg) so they are only
# imported by desktop/laptop profiles via collections/desktop.nix.
{ pkgs, config, ... }:

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
  home.packages = [
    # Wallpaper picker (rofi grid)
    (mkScript "hawker-rofi-wallpaper-select" (with pkgs; [ rofi swaybg findutils coreutils ]))

    # Desktop theme scripts
    (mkScript "hawker-rofi-theme-select" (with pkgs; [ rofi coreutils gnused libnotify ]))
    (mkScript "hawker-wallpaper-set" (with pkgs; [ swaybg coreutils findutils procps ]))
    (mkScript "hawker-wallpaper-next" (with pkgs; [ swaybg coreutils findutils procps libnotify ]))
  ];
}
