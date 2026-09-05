# Steam -- system-level only.
# User tools (mangohud, protonup-qt) are managed
# by Home Manager (home/gaming/tools.nix).
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.kernix;
  gs = cfg.gaming.gamescope;
  tvOutput = cfg.desktop.hyprland.tvOutput;

  # Parse resolution string "WIDTHxHEIGHT" into separate args.
  resParts = lib.splitString "x" gs.resolution;
  gsWidth = builtins.elemAt resParts 0;
  gsHeight = builtins.elemAt resParts 1;

  gsDefaults = import ../../../lib/gamescope.nix {
    host = cfg;
    inherit lib;
  };
in
  lib.mkIf cfg.gaming.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [proton-ge-bin];
      extraPackages = with pkgs; [
        pulseaudio # pactl -- Steam's scripts use it for audio device management
      ];

      # Translate X11 input events to uinput events so Steam Input's Desktop
      # Layout (mouse/keyboard emulation from the controller) works on Wayland.
      extest.enable = true;

      # Standalone gamescope session (Steam Deck game mode on the TV).
      # Creates `steam-gamescope` wrapper used by couch.nix on TTY3.
      gamescopeSession = {
        enable = true;
        args =
          ["-O" tvOutput "-W" gsWidth "-H" gsHeight "-r" (toString gs.refreshRate)]
          ++ gsDefaults.args;
        steamArgs = ["-gamepadui" "-pipewire-dmabuf"];
        env = gsDefaults.env;
      };
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false; # MUST be false -- the capability wrapper makes child processes
      # inherit cap_sys_nice, which causes Steam's bwrap sandbox to
      # call die() with "Unexpected capabilities but not setuid".
    };

    programs.gamemode.enable = true;

    # Udev rules for Steam hardware (Steam Controller, other controllers, HTC Vive).
    hardware.steam-hardware.enable = true;

    # ── Kernel modules ──
    # ntsync: kernel-level NT synchronization for Wine/Proton (kernel 6.13+).
    # hid_nintendo/hid_playstation: pre-load controller drivers for instant recognition.
    boot.kernelModules = ["ntsync" "hid_nintendo" "hid_playstation"];

    boot.kernel.sysctl = {
      # Valve/Proton recommended: raise vm.max_map_count for games with heavy
      # memory-mapped allocations (shaders, textures, large worlds).
      "vm.max_map_count" = 2147483642;

      # Recycle closed TCP sockets faster (default: 60s).
      # Prevents "address already in use" when restarting games quickly.
      "net.ipv4.tcp_fin_timeout" = 5;

      # Fix connectivity with ISPs/routers that have broken PMTU discovery.
      "net.ipv4.tcp_mtu_probing" = true;
    };
  }
