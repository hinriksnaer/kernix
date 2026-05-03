# Desktop theme scripts -- GUI pickers and wallpaper management.
# These pull in heavy dependencies (rofi, swaybg) so they are only
# imported by desktop/laptop profiles via collections/desktop.nix.
{ pkgs, config, ... }:

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
  home.packages = [
    # Wallpaper picker (rofi grid)
    (mkScript "kernix-rofi-wallpaper-select" (with pkgs; [ rofi swaybg findutils coreutils ]))

    # Desktop theme scripts
    (mkScript "kernix-rofi-theme-select" (with pkgs; [ rofi coreutils gnused libnotify ]))
    (mkScript "kernix-wallpaper-set" (with pkgs; [ swaybg coreutils findutils procps ]))
    (mkScript "kernix-wallpaper-next" (with pkgs; [ swaybg coreutils findutils procps libnotify ]))
  ];
}
