# Couch gaming mode -- standalone gamescope session on the TV.
# Desktop-only. Mutually exclusive with Hyprland (like Bazzite).
#
# Super+G: stops Hyprland, switches to TTY3, gamescope starts as sole compositor.
# On Steam exit: gamescope exits, chvt 1, Hyprland auto-restarts via UWSM.
#
# This architecture matches Bazzite/ChimeraOS: only one compositor owns the
# GPU at a time. Nvidia's DRM driver doesn't handle multiple compositors
# with concurrent DRM file descriptors.
#
# Key detail: kernix-couch uses systemd-run to spawn the transition in its
# own scope so it survives uwsm stop killing Hyprland's cgroup.
# Audio is set up in kernix-couch-session (on TTY3), not in kernix-couch,
# because uwsm stop may reset PipeWire state.
{
  lib,
  pkgs,
  hostname,
  ...
}:
lib.mkIf (hostname == "desktop") {
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "kernix-couch";
      runtimeInputs = [libnotify];
      text = ''
        # Toggle between desktop mode (TTY1) and couch mode (TTY3).
        # Mutually exclusive: Hyprland stops before gamescope starts.
        CURRENT_TTY=$(cat /sys/class/tty/tty0/active 2>/dev/null || echo "tty1")

        if [ "$CURRENT_TTY" = "tty3" ]; then
            # ── Switching BACK to desktop ──
            # Audio restore happens in kernix-couch-session after gamescope exits.
            sudo ${pkgs.kbd}/bin/chvt 1
        else
            # ── Switching TO couch mode ──
            notify-send -t 2000 "Couch Mode" "Switching to TV..."

            # Signal TTY3 to launch gamescope
            touch "$XDG_RUNTIME_DIR/kernix-couch-requested"

            # Spawn the transition in its own systemd scope so it survives
            # uwsm stop tearing down Hyprland's cgroup. The transient unit
            # runs independently of the compositor.
            systemd-run --user --unit=kernix-couch-transition --collect \
                kernix-couch-transition
        fi
      '';
    })

    (writeShellApplication {
      name = "kernix-couch-transition";
      runtimeInputs = [procps kbd util-linux];
      text = ''
        # Runs in its own systemd scope (not Hyprland's cgroup).
        # Stops Hyprland, waits for full exit, then switches to TTY3.

        # Stop Hyprland cleanly. UWSM terminates the session scope,
        # which releases all DRM file descriptors.
        uwsm stop

        # Wait for Hyprland to fully exit and release DRM resources.
        # Poll the process instead of arbitrary sleep to avoid Xid 32.
        while pgrep -x Hyprland >/dev/null 2>&1 || pgrep -x .Hyprland-wrapp >/dev/null 2>&1; do
            sleep 0.2
        done

        # Kill existing shell on TTY3 so getty respawns a fresh login.
        # The fresh shell's zsh initContent will see the sentinel file.
        # Use SIGHUP which is what logout sends.
        pkill -HUP -t tty3 2>/dev/null || true
        # Give getty a moment to respawn and auto-login
        sleep 0.5

        # Switch to TTY3 where gamescope will start.
        sudo ${pkgs.kbd}/bin/chvt 3
      '';
    })

    (writeShellApplication {
      name = "kernix-couch-session";
      runtimeInputs = [wireplumber];
      text = ''
        # Launched on TTY3 when sentinel file exists.
        # Runs gamescope as the sole DRM compositor (Hyprland is stopped).
        rm -f "$XDG_RUNTIME_DIR/kernix-couch-requested"

        # Bazzite session env setup
        export XDG_SESSION_TYPE=x11

        # Prevent xdg-desktop-portal from starting (no DISPLAY yet, would crash)
        systemctl --user set-environment XDG_DESKTOP_PORTAL_DIR=""
        # Remove stale DISPLAY/XAUTHORITY so gamescope sets its own
        systemctl --user unset-environment DISPLAY XAUTHORITY

        # ── Audio: switch to TV ──
        # Done here (not in kernix-couch) because uwsm stop may reset PipeWire state.
        wpctl set-profile 52 2 2>/dev/null || true
        sleep 0.3
        TV_SINK=""
        TV_SINK=$(wpctl status 2>/dev/null \
            | awk '/^Audio$/,/^Video$/' \
            | awk '/Sinks:/,/Sources:/' \
            | grep -v 'Sources:' \
            | grep -iE "HDMI.*Digital Stereo" \
            | head -1 \
            | grep -oE '[0-9]+\.' \
            | head -1 \
            | tr -d '.') || true
        if [ -n "$TV_SINK" ]; then
            wpctl set-default "$TV_SINK"
        fi

        # Raise file descriptor limit (games open many files)
        ulimit -n 524288

        # Run gamescope via the NixOS steam-gamescope wrapper.
        # All env vars (Bazzite-aligned) are set in the wrapper.
        steam-gamescope || true

        # ── Gamescope/Steam exited ──
        # Re-enable desktop portals
        systemctl --user unset-environment XDG_DESKTOP_PORTAL_DIR

        # Restore audio to ultrawide
        wpctl set-profile 52 1 2>/dev/null || true

        # Switch back to TTY1. Getty respawns, UWSM auto-starts Hyprland.
        sudo ${pkgs.kbd}/bin/chvt 1
      '';
    })
  ];

  # Launch gamescope session on TTY3 when sentinel file exists.
  # Must run BEFORE the UWSM auto-start (mkOrder 100) to prevent
  # Hyprland from launching on TTY3.
  programs.zsh.initContent = lib.mkOrder 50 ''
    if [[ "$(tty)" == "/dev/tty3" ]] && [[ -z "$WAYLAND_DISPLAY" ]] && [[ -z "$DISPLAY" ]]; then
      if [[ -f "$XDG_RUNTIME_DIR/kernix-couch-requested" ]]; then
        exec kernix-couch-session
      fi
    fi
  '';
}
