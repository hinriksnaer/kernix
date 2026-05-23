# Laptop profile -- user "hgudmund", terminal + desktop tools.
{
  settings,
  hostname,
  ...
}: let
  username = settings.hosts.${hostname}.username;
in {
  imports = [
    ../../home/terminal
    ../../home/desktop
    ../../home/apps
  ];

  monitors = settings.hosts.${hostname}.monitors;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
}
