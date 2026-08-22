# Steam -- system-level only.
# User tools (mangohud, protonup-qt) are managed
# by Home Manager (home/gaming/tools.nix).
{
  pkgs,
  config,
  ...
}: let
  # TV output connector for gamescope couch mode.
  # Read from the desktop host config (gaming is only imported by desktop).
  tvOutput = config.kernix.hosts.desktop.tvOutput;
  gsDefaults = import ./gamescope-defaults.nix;
in {
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
    # Shared env/args from gamescope-defaults.nix.
    gamescopeSession = {
      enable = true;
      args =
        ["-O" tvOutput "-W" "3840" "-H" "2160" "-r" "60"]
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
  # NixOS default is 1048576; Proton requires 2147483642.
  # https://github.com/ValveSoftware/Proton/wiki/Requirements
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;
}
