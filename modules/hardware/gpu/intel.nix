# Intel integrated graphics -- i915 kernel driver.
# GuC firmware submission, iHD VA-API, oneVPL (QSV) runtime.
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (config.kernix.gpu == "intel") {
  services.xserver.videoDrivers = ["modesetting"];

  boot.initrd.kernelModules = ["i915"];
  boot.kernelModules = ["i915"];
  boot.kernelParams = ["i915.enable_guc=3"];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD) userspace
      vpl-gpu-rt # oneVPL (QSV) runtime
    ];
  };

  hardware.enableRedistributableFirmware = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
}
