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

    # Valve/Proton recommended: raise vm.max_map_count for games with heavy
    # memory-mapped allocations (shaders, textures, large worlds).
    boot.kernel.sysctl."vm.max_map_count" = 2147483642;
  }
