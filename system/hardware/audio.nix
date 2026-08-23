# Audio -- system-level only.
# User tools (pavucontrol, pamixer, volume-control) are managed
# by Home Manager (home/desktop/audio.nix).
{
  config,
  lib,
  ...
}:
lib.mkIf config.kernix.hardware.enable {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  users.users.${config.kernix.username}.extraGroups = ["audio"];
}
