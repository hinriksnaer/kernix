# SwayOSD -- GTK-based on-screen display for volume/brightness.
# Replaces the custom volume-control/brightness-control shell scripts
# with a proper client-server architecture that handles rapid input.
{...}: {
  services.swayosd.enable = true;
}
