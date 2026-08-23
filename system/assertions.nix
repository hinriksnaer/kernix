# Configuration assertions -- catch misconfigurations at eval time.
{
  config,
  lib,
  ...
}: let
  cfg = config.kernix;
in {
  config.assertions = [
    {
      assertion = cfg.gaming.enable -> cfg.gpu != "none";
      message = "kernix.gaming.enable requires kernix.gpu to be set (nvidia, intel, or amd).";
    }
    {
      assertion = (cfg.gaming.enable && cfg.gaming.couch.enable) -> cfg.desktop.hyprland.tvOutput != "";
      message = "kernix.gaming.couch.enable requires kernix.desktop.hyprland.tvOutput to be set.";
    }
    {
      assertion = cfg.desktop.hyprland.hdr -> cfg.desktop.enable;
      message = "kernix.desktop.hyprland.hdr requires kernix.desktop.enable.";
    }
  ];

  config.warnings =
    lib.optional (cfg.gaming.enable && cfg.gaming.sunshine.enable && cfg.gpu == "none")
    "kernix.gaming.sunshine.enable is set but kernix.gpu is 'none'. Sunshine needs a GPU encoder.";
}
