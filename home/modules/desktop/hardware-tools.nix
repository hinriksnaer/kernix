# Hardware user tools -- brightness, bluetooth, sensors.
# System-level parts (user groups, hardware.bluetooth, services.blueman)
# stay in their respective NixOS modules.
{pkgs, ...}: {
  home.packages = with pkgs; [
    bluetui
    brightnessctl
    lm_sensors
  ];
}
