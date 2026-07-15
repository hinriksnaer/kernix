# Sunshine -- game stream host for Moonlight (Steam Deck).
# Provides system-level plumbing: firewall, udev, avahi, capabilities, config.
#
# autoStart is OFF -- Sunshine is lifecycle-managed by kernix-couch-session
# (home/gaming/couch.nix). It starts alongside gamescope on TTY3 and stops
# when the couch session exits. This avoids running Sunshine on the desktop
# session where it isn't needed.
#
# First-time setup:
#   1. Rebuild: sudo nixos-rebuild switch --flake .#desktop
#   2. Enter couch mode (Super+G) -- Sunshine starts automatically
#   3. Open https://localhost:47990 to set username/password
#   4. On Steam Deck: install Moonlight, add host <desktop-ip>:47989
#   5. Enter the PIN shown in Moonlight into Sunshine's web UI
{
  pkgs,
  config,
  ...
}: let
  inherit (config.kernix) username;
in {
  services.sunshine = {
    enable = true;
    autoStart = false; # Managed by kernix-couch-session, not graphical-session.target
    capSysAdmin = true; # DRM/KMS capture on gamescope's DRM session
    openFirewall = true; # TCP+UDP 47984-47990

    settings = {
      sunshine_name = "kernix-desktop";
      min_log_level = "info";
      capture = "kms"; # KMS capture for gamescope DRM session
      encoder = "nvenc"; # Force NVENC -- fail loudly rather than fall back to software

      # ── NVENC tuning for low-latency streaming ──
      nvenc_preset = 1; # P1 fastest, lowest latency
      nvenc_twopass = "quarter_res"; # Good bitrate distribution, minimal overhead

      # ── Codec: HEVC with HDR support ──
      # ~40% better quality at the same bitrate vs H.264.
      # Steam Deck's hardware decoder handles HEVC natively.
      # Mode 3 advertises both Main (SDR) and Main10 (HDR) profiles.
      hevc_mode = 3; # HEVC Main + Main10 (HDR)

      # ── Input ──
      # Cap mouse event rate: Steam Deck trackpads generate thousands of
      # events/sec via Moonlight. Gamescope chokes on high-frequency mouse
      # input (ValveSoftware/gamescope#1279).
      mouse_rate_limit = 250;

      # Force Xbox One controller emulation. The default (auto) detects the
      # Deck's touchpad/motion and creates a DS4/DS5 virtual controller,
      # which floods gamescope with extra touchpad + motion sensor events
      # on every input, causing stutter. Xbox One emulation is a clean
      # gamepad with no extra event sources.
      gamepad = "xone";
      motion_as_ds4 = "disabled";
      touchpad_as_ds4 = "disabled";

      # ── Network: low-latency LAN ──
      lan_encryption_mode = 0; # No encryption on local network
      fec_percentage = 10; # Lower FEC overhead (default 20), fine on reliable LAN
    };

    applications = {
      env = {
        PATH = "$(PATH):$(HOME)/.local/bin";
      };
      apps = [
        {
          name = "Desktop";
          image-path = "desktop.png";
        }
        {
          name = "Steam Big Picture";
          detached = ["sudo -u ${username} setsid steam steam://open/bigpicture"];
          prep-cmd = [
            {
              do = "";
              undo = "sudo -u ${username} setsid steam steam://close/bigpicture";
            }
          ];
          image-path = "steam.png";
        }
      ];
    };
  };

  # Fix CUDA/NVENC for the capSysAdmin security wrapper.
  #
  # Problem: ffmpeg uses dlopen("libcuda.so.1") which only searches the
  # standard library path. On NixOS, nvidia libs live at
  # /run/opengl-driver/lib, not in dlopen's search path. The security
  # wrapper also strips LD_LIBRARY_PATH from the environment.
  #
  # Fix: override the sunshine package with makeWrapper to bake
  # LD_LIBRARY_PATH into the wrapper script. The security wrapper
  # (setcap ELF) execs our shell wrapper, which hardcodes the export,
  # then execs the real sunshine binary with nvidia libs discoverable.
  services.sunshine.package = let
    sunshine-nvenc = pkgs.sunshine.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postFixup =
        (old.postFixup or "")
        + ''
          wrapProgram $out/bin/sunshine \
            --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
        '';
    });
  in
    sunshine-nvenc;

  # Virtual input devices (mouse/keyboard/gamepad emulation)
  users.users.${username}.extraGroups = ["uinput"];
}
