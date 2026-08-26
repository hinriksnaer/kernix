# User-level fonts -- packages, rendering settings, and fontconfig defaults.
# HM installs fonts into ~/.nix-profile/share/fonts/ and writes
# ~/.config/fontconfig/fonts.conf, which fontconfig scans on both NixOS
# and non-NixOS (Fedora) systems. On NixOS, system/desktop/fonts.nix
# additionally covers system-wide paths (login screen, other users).
{
  pkgs,
  host,
  lib,
  ...
}:
lib.mkIf host.desktop.enable {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [host.font.monospace];
      sansSerif = ["Noto Sans"];
      serif = ["Noto Serif"];
      emoji = ["Noto Color Emoji"];
    };
    antialiasing = true;
    hinting = "full";
    subpixelRendering = "rgb";
  };

  home.packages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    google-fonts
    maple-mono.NF
    nerd-fonts.symbols-only
  ];
}
