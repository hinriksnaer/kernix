# Shared gamescope session defaults.
# Imported by both system/gaming/steam.nix (NixOS module) and
# home/gaming/couch.nix (Home Manager module) to avoid duplication.
# Pure data -- no module system involvement.
{
  # Environment variables from gamescope-session-plus (Bazzite/ChimeraOS).
  # Critical for stable rendering, especially on Nvidia.
  env = {
    # -- Nvidia --
    __GL_CONSTANT_FRAME_RATE_HINT = "3"; # Nvidia frame pacing fix (from bazzite-steam)

    # -- Rendering stability --
    GAMESCOPE_DISABLE_ASYNC_FLIPS = "1"; # prevents frame buffer ordering/jitter
    vk_xwayland_wait_ready = "false"; # don't wait for client buffers to idle
    ENABLE_GAMESCOPE_WSI = "1"; # force gamescope Vulkan WSI layer
    mesa_glthread = "true"; # better frame timing

    # -- Shader compilation --
    DXVK_ASYNC = "1"; # async shader compilation (no stutter, placeholders until ready)

    # -- HDR --
    ENABLE_HDR_WSI = "1"; # Gamescope HDR WSI layer for HDR-aware clients
    DXVK_HDR = "1"; # DXVK HDR output for DirectX games via Proton

    # -- Game compatibility --
    SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0"; # prevent games minimizing on focus loss
    VKD3D_SWAPCHAIN_LATENCY_FRAMES = "3"; # workaround vkd3d-proton swapchain starvation
    GAMESCOPE_NV12_COLORSPACE = "k_EStreamColorspace_BT601"; # NV12 color space (Remote Play)
    QT_QPA_PLATFORM = "xcb"; # Qt apps under xwayland inside gamescope
  };

  # Common gamescope CLI args (resolution/output added per-consumer).
  args = [
    "--backend"
    "drm"
    "--force-grab-cursor"
    "--xwayland-count"
    "2"
    "--hide-cursor-delay"
    "3000" # hide cursor after 3s (couch UX)
    "--fade-out-duration"
    "200" # smooth focus transitions
    # HDR output (TV must support HDR10)
    "--hdr-enabled"
    "--hdr-itm-enabled" # SDR->HDR inverse tone mapping
    "--hdr-sdr-content-nits"
    "400" # SDR content brightness in HDR mode
    "--hdr-itm-sdr-nits"
    "400" # SDR input luminance for ITM
    "--hdr-itm-target-nits"
    "1000" # HDR target peak luminance for ITM
    "--mangoapp" # Performance overlay via MangoHud (toggle in Steam QAM)
  ];
}
