# Desktop theme scripts -- GUI pickers and wallpaper management.
# These pull in heavy dependencies (rofi, swaybg) so they are only
# imported by desktop/laptop profiles via collections/desktop.nix.
{ pkgs, config, ... }:

let
  hawkerPath = "${config.home.homeDirectory}/.local/share/hawker";
  scripts = ./scripts;

  mkFish = name: pkgs.writeScriptBin name ''
    #!${pkgs.fish}/bin/fish
    set -gx HAWKER_PATH "${hawkerPath}"
    ${builtins.readFile "${scripts}/${name}.fish"}
  '';
in
{
  home.packages = [
    # Wallpaper picker (bash, uses rofi)
    (pkgs.writeShellApplication {
      name = "hawker-rofi-wallpaper-select";
      runtimeInputs = with pkgs; [ rofi swaybg findutils coreutils ];
      text = builtins.readFile "${scripts}/hawker-rofi-wallpaper-select.sh";
      excludeShellChecks = [ "SC2029" "SC2016" ];
    })

    # Desktop theme scripts (fish)
    (mkFish "hawker-rofi-theme-select")
    (mkFish "hawker-wallpaper-set")
    (mkFish "hawker-wallpaper-next")
  ];
}
