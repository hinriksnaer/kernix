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

    # Low-latency defaults for gaming.
    # quantum = buffer size per cycle; rate = sample rate.
    # 512/48000 ≈ 10.7 ms latency -- good balance between low latency
    # and avoiding xruns on desktop hardware.
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 2048;
      };
    };
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  users.users.${config.kernix.username}.extraGroups = ["audio"];
}
