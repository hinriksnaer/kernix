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
    hostType = "hm";
    hmProfile = "${username}@${hostname}";
  };
in {
  home.packages = [cli.kernix];
}
