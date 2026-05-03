# Gaming overlays and Proton management.
# System-level parts (programs.steam, gamescope, gamemode) stay in
# modules/gaming/steam.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    mangohud
    protonup-qt
  ];
}
