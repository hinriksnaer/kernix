# Remote server profile -- non-NixOS host with Nix installed.
# Apply with: home-manager switch --flake ~/kernix#<user>@remote
{
  pkgs,
  host,
  hostname,
  ...
}: let
  username = host.username;
  cli = import ../../cli {
    inherit pkgs;
    hmProfile = "${username}@${hostname}";
  };
in {
  # kernix-hm-switch: pull latest + home-manager switch
  home.packages = [cli.kernix-hm-switch];
}
