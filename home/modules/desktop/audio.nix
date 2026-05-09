# Audio control tools.
# System-level parts (PipeWire, rtkit, user groups) stay in
# modules/hardware/audio.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    pavucontrol
    pamixer
    playerctl
    alsa-utils
  ];
}
