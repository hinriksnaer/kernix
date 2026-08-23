# Home Manager entry point.
# Receives hostname from flake.nix. The host config attrset is passed
# via extraSpecialArgs and available to all modules as the `host` arg.
{hostname}: {
  host,
  lib,
  ...
}: let
  username = host.username;
  homePrefix = host.homePrefix;
  homeDirectory =
    if username == "root"
    then "/root"
    else "${homePrefix}/${username}";
in {
  imports = [
    # All modules imported -- leaf modules gate themselves via lib.mkIf host.*
    ./terminal
    ./desktop
    ./apps
    ./gaming
    ./nixtorch.nix
    ./theme
    ../hosts/${hostname}/home.nix
  ];

  programs.home-manager.enable = true;

  # ── Common user identity ──
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.11";

  # Expose username to scripts/dotfiles at runtime
  home.sessionVariables.KERNIX_USER = username;
  home.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
}
