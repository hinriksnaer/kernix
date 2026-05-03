# NVIDIA proprietary driver -- discrete GPU.
# Kernel modules, modesetting, VAAPI (nvidia-vaapi-driver),
# container toolkit, and session variables.
{ config, lib, pkgs, ... }:

lib.mkIf (config.hawker.gpu == "nvidia") {
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # NVIDIA container toolkit for podman / docker
  hardware.nvidia-container-toolkit.enable = true;
}
