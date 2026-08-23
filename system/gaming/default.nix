# Gaming -- sub-modules declare their own options.
{
  config,
  lib,
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

    # 32-bit graphics libraries for Steam/Proton
    hardware.graphics.enable32Bit = true;
  };
}
