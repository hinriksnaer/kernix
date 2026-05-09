# Audio control tools.
# System-level parts (PipeWire, rtkit, user groups) stay in
# modules/hardware/audio.nix.
{pkgs, ...}: {
  home.packages = with pkgs; [
    pavucontrol
    pamixer
    playerctl
    alsa-utils
    (writeShellApplication {
      name = "volume-control";
      runtimeInputs = [wireplumber libnotify];
      text = builtins.readFile ./scripts/volume-control.sh;
    })
    (writeShellApplication {
      name = "rofi-audio-select";
      runtimeInputs = [rofi wireplumber libnotify gawk];
      text = builtins.readFile ./scripts/rofi-audio-select.sh;
    })
  ];
}
