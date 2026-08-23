# Couch gaming session -- standalone gamescope on TTY3.
# Gamescope runs as a DRM compositor via libseat, coexisting with
# Hyprland on TTY1. logind handles DRM master transfer on VT switch.
#
# Architecture:
#   TTY1: Hyprland (desktop mode) -- always running
#   TTY3: Auto-login, gamescope launched on-demand via sentinel file
#
# Super+G creates sentinel + chvt 3. When Steam exits, chvt 1.
{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.kernix;
  inherit (cfg) username;
in
  lib.mkIf (cfg.gaming.enable && cfg.gaming.couch.enable) {
    # Auto-login on TTY3 so gamescope can start without user interaction.
    systemd.services."getty@tty3" = {
      overrideStrategy = "asDropin";
      serviceConfig = {
        ExecStart = ["" "${pkgs.util-linux}/bin/agetty --autologin ${username} --noclear tty3 $TERM"];
      };
    };

    # Passwordless chvt for the user (VT switching for couch mode)
    security.sudo.extraRules = [
      {
        users = [username];
        commands = [
          {
            command = "${pkgs.kbd}/bin/chvt";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  }
