# Desktop profile -- user "softmax", terminal + desktop tools.
{ settings, hostname, ... }:

let
  username = settings.hosts.${hostname}.username;
in
{
  imports = [
    ../collections/terminal.nix
    ../collections/desktop.nix
    ../collections/apps.nix
    ../collections/gaming.nix
  ];

  monitors = settings.hosts.${hostname}.monitors;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
}
