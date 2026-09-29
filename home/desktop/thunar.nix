# Thunar -- XFCE file manager.
# GTK-based, respects Adwaita dark via dconf color-scheme.
# System-level gvfs is needed for trash and remote mounts --
# enable services.gvfs in the NixOS config if not already present.
{
  pkgs,
  host,
  lib,
  ...
}:
lib.mkIf host.desktop.enable {
  home.packages = with pkgs; [
    thunar
    thunar-volman # removable device management
    thunar-archive-plugin # archive integration (create/extract)
    tumbler # thumbnail generation
  ];
}
