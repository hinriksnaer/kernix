{lib, ...}: {
  options.kernix.desktop.hyprland = {
    layout = lib.mkOption {
      type = lib.types.enum ["dwindle" "master"];
      default = "dwindle";
      description = "Hyprland window layout.";
    };
    tvOutput = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "DRM connector name for the TV output (e.g. HDMI-A-2). Empty if no TV.";
    };
    hdr = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable HDR/wide-gamut output on the primary monitor.";
    };
  };
}
