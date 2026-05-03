# AMD discrete / APU graphics -- amdgpu kernel driver.
# radeonsi VA-API, AMDVLK Vulkan.
{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (config.kernix.gpu == "amd") {
  services.xserver.videoDrivers = ["amdgpu"];

  boot.initrd.kernelModules = ["amdgpu"];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [amdvlk];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
  };
}
