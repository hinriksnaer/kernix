# nh -- Nix Helper for cleaner rebuild UX.
# Provides diff display, nix-output-monitor, and automatic GC.
# Usage: nh os switch, nh os boot, nh os test, nh clean all
{config, ...}: let
  cfg = config.kernix;
  homeDir =
    if cfg.username == "root"
    then "/root"
    else "${cfg.homePrefix}/${cfg.username}";
  flakePath =
    if cfg.kernixRoot != ""
    then cfg.kernixRoot
    else "${homeDir}/kernix";
in {
  programs.nh = {
    enable = true;
    flake = flakePath;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
  };
}
