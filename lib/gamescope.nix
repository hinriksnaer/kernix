# Shared gamescope session defaults.
# Called by system/gaming/steam and home/gaming/couch.
# Returns { env, args } parameterized by host config.
{
  host,
  lib,
}: let
  gs = host.gaming.gamescope;
  isNvidia = host.gpu == "nvidia";
  hasHdr = host.desktop.hyprland.hdr;
in {
  # Environment variables from gamescope-session-plus (Bazzite/ChimeraOS).
  env =
    {
      # -- Rendering stability --
      # NOTE: gamescope forces vk_xwayland_wait_ready=false on its children
      # itself, so it is intentionally not duplicated here.
      GAMESCOPE_DISABLE_ASYNC_FLIPS = "1";
      ENABLE_GAMESCOPE_WSI = "1";
      mesa_glthread = "true";

      # -- Game compatibility --
      SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
      VKD3D_SWAPCHAIN_LATENCY_FRAMES = "3";
      QT_QPA_PLATFORM = "xcb";

      # NV12 color space for Remote Play Together / Wayland.
      # Upstream uses BT601 but that causes glitches and artifacts on
      # this NVIDIA + HDMI-A-1 TV setup. BT709 is stable here.
      GAMESCOPE_NV12_COLORSPACE = "k_EStreamColorspace_BT709";
    }
    // lib.optionalAttrs hasHdr {
      # -- HDR (only when HDR output is enabled) --
      ENABLE_HDR_WSI = "1";
      DXVK_HDR = "1";
    }
    // lib.optionalAttrs isNvidia {
      # -- NVAPI / raytracing (DLSS, DXR, RT cores) --
      PROTON_ENABLE_NVAPI = "1";
      DXVK_ENABLE_NVAPI = "true";
      VKD3D_FEATURE_LEVEL = "12_2";
    };

  # Common gamescope CLI args (resolution/output added per-consumer).
  args =
    [
      "--backend"
      "drm"
      "--force-grab-cursor"
      "--xwayland-count"
      "2"
      "--hide-cursor-delay"
      "3000"
      "--fade-out-duration"
      "200"
    ]
    ++ lib.optional gs.adaptiveSync "--adaptive-sync"
    ++ lib.optionals hasHdr [
      "--hdr-enabled"
      "--hdr-itm-enabled"
      "--hdr-sdr-content-nits"
      (toString gs.hdr.sdrContentNits)
      "--hdr-itm-sdr-nits"
      (toString gs.hdr.itmSdrNits)
      "--hdr-itm-target-nits"
      (toString gs.hdr.itmTargetNits)
    ];
}
