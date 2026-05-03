# Audio control tools.
# System-level parts (PipeWire, rtkit, user groups) stay in
# modules/hardware/audio/default.nix.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pavucontrol
    pamixer
    playerctl
    alsa-utils
    (writeScriptBin "volume-control" ''
      #!${fish}/bin/fish
      ${builtins.readFile ./scripts/volume-control.fish}
    '')
  ];
}
