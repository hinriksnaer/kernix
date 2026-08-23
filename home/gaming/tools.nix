# Gaming overlays and Proton management.
# System-level parts (programs.steam, gamescope, gamemode) stay in
# system/gaming/steam.nix.
{
  pkgs,
  host,
  lib,
  ...
}:
lib.mkIf host.gaming.enable {
  home.packages = with pkgs; [
    mangohud
    protonup-qt
  ];
}
