# Gaming -- sub-modules declare their own options.
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./options.nix
    ./steam
    ./couch
    ./sunshine
  ];

  config = lib.mkIf config.kernix.gaming.enable {
    # Gaming implies desktop
    kernix.desktop.enable = lib.mkDefault true;

    # 32-bit graphics libraries and gamescope WSI layer for Steam/Proton.
    hardware.graphics = {
      enable32Bit = true;
      extraPackages = [pkgs.gamescope-wsi];
      extraPackages32 = [pkgs.pkgsi686Linux.gamescope-wsi];
    };

    # Kill runaway processes before the system fully OOMs and freezes.
    services.earlyoom = {
      enable = true;
      # Kill at 4% free RAM / 4% free swap (sensible for 32-64 GB desktop).
      freeMemThreshold = 4;
      freeSwapThreshold = 4;
    };
  };
}
