# Remote server profile -- non-NixOS host with Nix installed.
# Apply with: home-manager switch --flake ~/kernix#<user>@remote
{
  pkgs,
  settings,
  hostname,
  ...
}: let
  username = settings.hosts.${hostname}.username;
  cli = import ../../cli {
    inherit pkgs;
    hmProfile = "${username}@${hostname}";
  };
in {
  imports = [
    ../../home/terminal
  ];

  # kernix-hm-switch: pull latest + home-manager switch
  home.packages = [cli.kernix-hm-switch];
}
