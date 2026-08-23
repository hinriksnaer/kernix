# Sunshine -- game stream host for Moonlight (Steam Deck).
# Provides system-level plumbing: firewall, udev, avahi, capabilities, config.
#
# autoStart is OFF -- Sunshine is lifecycle-managed by kernix-couch-session
# (home/gaming/couch.nix). It starts alongside gamescope on TTY3 and stops
# when the couch session exits.
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
  lib,
  ...
}: let
  cfg = config.kernix;
  inherit (cfg) username;
  isNvidia = cfg.gpu == "nvidia";
  encoder =
    if isNvidia
    then "nvenc"
    else if cfg.gpu == "amd"
    then "vaapi"
    else "software";
in
  lib.mkIf (cfg.gaming.enable && cfg.gaming.sunshine.enable) {
    services.sunshine = {
      enable = true;
      autoStart = false;
      capSysAdmin = true;
      openFirewall = true;

      settings = {
        sunshine_name = "kernix";
        min_log_level = "info";
        capture = "kms";
        encoder = encoder;

        nvenc_preset = 1;
        nvenc_twopass = "quarter_res";
        hevc_mode = 3;
        mouse_rate_limit = 250;

        gamepad = "xone";
        motion_as_ds4 = "disabled";
        touchpad_as_ds4 = "disabled";

        lan_encryption_mode = 0;
        fec_percentage = 10;
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

    # Fix CUDA/NVENC for the capSysAdmin security wrapper (NVIDIA only).
    services.sunshine.package = lib.mkIf isNvidia (let
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
      sunshine-nvenc);

    # Virtual input devices (mouse/keyboard/gamepad emulation)
    users.users.${username}.extraGroups = ["uinput"];
  }
