# Home Manager entry point.
# Receives hostname and settings from flake.nix, imports the
# matching host profile which opts into shared modules.
{
  hostname,
  settings,
}: let
  hostCfg = settings.hosts.${hostname};
  username = hostCfg.username;
  homePrefix = hostCfg.homePrefix or "/home";
  homeDirectory =
    if username == "root"
    then "/root"
    else "${homePrefix}/${username}";
in
  {...}: {
    imports = [
      ../hosts/${hostname}/home.nix
      ./nixtorch.nix
    ];

    # Make settings available to all modules
    _module.args = {
      inherit settings hostname;
    };

    programs.home-manager.enable = true;

    # ── Common user identity ──
    home.username = username;
    home.homeDirectory = homeDirectory;
    home.stateVersion = "24.11";

    # Expose username to scripts/dotfiles at runtime
    home.sessionVariables.KERNIX_USER = username;
    home.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  }
