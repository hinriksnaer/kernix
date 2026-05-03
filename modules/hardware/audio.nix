# Audio -- system-level only.
# User tools (pavucontrol, pamixer, volume-control) are managed
# by Home Manager (home/modules/desktop/audio.nix).
{ config, ... }:

{
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

  users.users.${config.hawker.username}.extraGroups = [ "audio" ];
}
