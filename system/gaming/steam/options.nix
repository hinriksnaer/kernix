{lib, ...}: {
  options.kernix.gaming.gamescope = {
    resolution = lib.mkOption {
      type = lib.types.str;
      default = "3840x2160";
      description = "Gamescope output resolution (e.g. 3840x2160).";
    };
    refreshRate = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Gamescope output refresh rate.";
    };
    hdr = {
      sdrContentNits = lib.mkOption {
        type = lib.types.int;
        default = 400;
        description = "SDR content brightness in HDR mode.";
      };
      itmSdrNits = lib.mkOption {
        type = lib.types.int;
        default = 400;
        description = "SDR input luminance for inverse tone mapping.";
      };
      itmTargetNits = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "HDR target peak luminance for inverse tone mapping.";
      };
    };
  };
}
