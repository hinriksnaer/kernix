# NVIDIA gaming session variables -- G-Sync and VRR.
# System-level parts (driver, kernel modules, container toolkit) stay in
# system/hardware/gpu/nvidia.nix.
{
  lib,
  host,
  ...
}:
lib.mkIf (host.gaming.enable && host.gpu == "nvidia") {
  home.sessionVariables = {
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";

    # NVAPI / raytracing (DLSS, DXR, RT cores)
    PROTON_ENABLE_NVAPI = "1";
    DXVK_ENABLE_NVAPI = "true";
    VKD3D_FEATURE_LEVEL = "12_2";
  };
}
