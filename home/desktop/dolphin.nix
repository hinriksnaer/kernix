# Dolphin -- KDE file manager.
{
  pkgs,
  host,
  lib,
  ...
}:
lib.mkIf host.desktop.enable {
  home.packages = with pkgs.kdePackages; [
    dolphin
    qtsvg # SVG icon support
    ark # archive manager (zip, tar, 7z, etc.)
    kio-extras # extra protocols (sftp, fish, etc.)
  ];

  # Force Breeze Dark for KDE/Qt apps (Dolphin, Ark, etc.)
  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
  '';
}
