# nh -- Nix Helper for cleaner rebuild UX.
# Provides diff display, nix-output-monitor, and automatic GC.
# Usage: nh os switch, nh os boot, nh os test, nh clean all
{ config, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/${config.hawker.username}/hawker";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
  };
}
