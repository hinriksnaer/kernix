# Steam -- system-level only.
# User tools (mangohud, protonup-qt) are managed
# by Home Manager (home/gaming/tools.nix).
{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = with pkgs; [proton-ge-bin];
    extraPackages = with pkgs; [
      pulseaudio # pactl -- Steam's scripts use it for audio device management
    ];

    # Standalone gamescope session (Steam Deck game mode on the TV).
    # Creates `steam-gamescope` wrapper used by couch.nix on TTY3.
    gamescopeSession = {
      enable = true;
      args = [
        "--backend"
        "drm"
        "-O"
        "HDMI-A-2"
        "-W"
        "3840"
        "-H"
        "2160" # output at TV native 4K
        "-r"
        "60"
        "--force-grab-cursor"
        "--xwayland-count"
        "2"
        "--hide-cursor-delay"
        "3000" # hide cursor after 3s (couch UX)
        "--fade-out-duration"
        "200" # smooth focus transitions
      ];
      steamArgs = ["-gamepadui" "-pipewire-dmabuf"];

      # Environment from gamescope-session-plus (Bazzite/ChimeraOS).
      # Critical for stable rendering, especially on Nvidia.
      env = {
        # -- Nvidia --
        __GL_CONSTANT_FRAME_RATE_HINT = "3"; # Nvidia frame pacing fix (from bazzite-steam)

        # -- Rendering stability --
        GAMESCOPE_DISABLE_ASYNC_FLIPS = "1"; # prevents frame buffer ordering/jitter
        vk_xwayland_wait_ready = "false"; # don't wait for client buffers to idle
        ENABLE_GAMESCOPE_WSI = "1"; # force gamescope Vulkan WSI layer
        mesa_glthread = "true"; # better frame timing

        # -- Game compatibility --
        SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0"; # prevent games minimizing on focus loss
        VKD3D_SWAPCHAIN_LATENCY_FRAMES = "3"; # workaround vkd3d-proton swapchain starvation
        GAMESCOPE_NV12_COLORSPACE = "k_EStreamColorspace_BT601"; # NV12 color space (Remote Play)
        QT_QPA_PLATFORM = "xcb"; # Qt apps under xwayland inside gamescope
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = false; # MUST be false -- the capability wrapper makes child processes
    # inherit cap_sys_nice, which causes Steam's bwrap sandbox to
    # call die() with "Unexpected capabilities but not setuid".
  };

  programs.gamemode.enable = true;
}
