# Audio control tools.
# System-level parts (PipeWire, rtkit, user groups) stay in
# system/hardware/audio.nix.
# Note: rofi-audio-select moved to hyprland/launcher/rofi/ since it's launcher-specific.
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
  ];
}
