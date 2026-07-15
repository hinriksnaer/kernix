# Desktop profile -- user "softmax", terminal + desktop tools.
{
  settings,
  hostname,
  ...
}: {
  imports = [
    ../../home/terminal
    ../../home/desktop
    ../../home/apps
    ../../home/gaming
  ];

  # TV (HDMI-A-2) is NOT added to Hyprland monitors -- it's only used by
  # the standalone gamescope session on TTY3 (couch/game mode).
  monitors = settings.hosts.${hostname}.monitors;
}
