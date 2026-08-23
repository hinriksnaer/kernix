# Gaming -- sub-modules declare their own options.
{
  config,
  lib,
  ...
}: {
  imports = [
    ./options.nix
    ./gpu-extra.nix
    ./steam
    ./couch
    ./sunshine
  ];

  # Gaming implies desktop
  config = lib.mkIf config.kernix.gaming.enable {
    kernix.desktop.enable = lib.mkDefault true;
  };
}
