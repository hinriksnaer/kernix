# Laptop profile -- user "hgudmund", terminal + desktop tools.
{
  settings,
  hostname,
  ...
}: {
  imports = [
    ../../home/terminal
    ../../home/desktop
    ../../home/apps
  ];

  monitors = settings.hosts.${hostname}.monitors;
}
