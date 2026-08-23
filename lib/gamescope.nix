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
      GAMESCOPE_DISABLE_ASYNC_FLIPS = "1";
      vk_xwayland_wait_ready = "false";
      ENABLE_GAMESCOPE_WSI = "1";
      mesa_glthread = "true";

      # -- Shader compilation --
      DXVK_ASYNC = "1";

      # -- Game compatibility --
      PROTON_NO_FSYNC = "1";
      SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
      VKD3D_SWAPCHAIN_LATENCY_FRAMES = "3";
      GAMESCOPE_NV12_COLORSPACE = "k_EStreamColorspace_BT601";
      QT_QPA_PLATFORM = "xcb";
    }
    // lib.optionalAttrs hasHdr {
      # -- HDR (only when HDR output is enabled) --
      ENABLE_HDR_WSI = "1";
      DXVK_HDR = "1";
    }
    // lib.optionalAttrs isNvidia {
      __GL_CONSTANT_FRAME_RATE_HINT = "3";
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
