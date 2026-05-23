# Desktop profile -- user "softmax", terminal + desktop tools.
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
    ../../home/gaming
  ];

  monitors = settings.hosts.${hostname}.monitors;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
}
