# Desktop profile -- user "hawker", terminal + desktop tools.
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

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
}
