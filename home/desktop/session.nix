# Desktop session -- user-level packages, cursor, dconf, and session variables.
# System-level parts (polkit, PAM limits, programs.dconf.enable) stay in
# system/desktop/desktop-session.nix.
{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    polkit_gnome
    adwaita-icon-theme
    hyprcursor
    gsettings-desktop-schemas
    glib
    xdg-user-dirs
    xdg-utils
    networkmanagerapplet
    libnotify
  ];

  # Cursor theme (replaces NixOS environment.etc."icons/default/index.theme"
  # and cursor-related environment.sessionVariables)
  home.pointerCursor = {
    name = "Adwaita";
    size = 24;
    package = pkgs.adwaita-icon-theme;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  # Dark mode (replaces NixOS programs.dconf.profiles.user.databases)
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    TERMINAL = "ghostty";
  };
}
