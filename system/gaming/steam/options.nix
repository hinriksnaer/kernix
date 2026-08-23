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
        description = "How bright SDR content appears on screen in HDR mode (gamescope default: 400).";
      };
      itmSdrNits = lib.mkOption {
        type = lib.types.int;
        default = 100;
        description = "Assumed input luminance of SDR content for inverse tone mapping (gamescope default: 100).";
      };
      itmTargetNits = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "HDR target peak luminance for inverse tone mapping.";
      };
    };
  };
}
