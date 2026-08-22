# Couch gaming mode -- standalone gamescope session on the TV.
# Desktop-only. Mutually exclusive with Hyprland (like Bazzite).
#
# Super+G:       TV mode   (3840x2160 16:9)
# Super+Shift+G: Deck mode (1280x800  16:10)
#
# Both stop Hyprland, switch to TTY3, gamescope starts as sole
# compositor with Sunshine streaming in the background.
# On Steam exit: gamescope exits, Sunshine stops, chvt 1, Hyprland
#                auto-restarts via UWSM.
#
# Only one compositor owns the GPU at a time. Nvidia's DRM driver
# doesn't handle multiple compositors with concurrent DRM file descriptors.
#
# Key detail: kernix-couch uses systemd-run to spawn the transition in
# its own scope so it survives uwsm stop killing Hyprland's cgroup.
# Audio is set up in kernix-couch-session (on TTY3), not in kernix-couch,
# because uwsm stop may reset PipeWire state.
{
  lib,
  pkgs,
  hostname,
  settings,
  ...
}: let
  tvOutput = settings.hosts.${hostname}.tvOutput or "";
  gsDefaults = import ../../system/gaming/gamescope-defaults.nix;

  # Convert shared gamescope env attrset to shell VAR=val prefix lines.
  gsEnvStr = lib.concatStringsSep " \\\n          " (
    lib.mapAttrsToList (k: v: "${k}=${v}") gsDefaults.env
  );

  # Convert shared gamescope args list to shell arguments.
  gsArgsStr = lib.concatStringsSep " " gsDefaults.args;
in
  lib.mkIf (hostname == "desktop") {
    home.packages = with pkgs; [
      # ── Trigger: Couch mode ──
      # Usage: kernix-couch [tv|deck]   (default: tv)
      #   Super+G       -> kernix-couch tv    (3840x2160)
      #   Super+Shift+G -> kernix-couch deck  (1280x800)
      (writeShellApplication {
        name = "kernix-couch";
        runtimeInputs = [libnotify];
        text = ''
          MODE="''${1:-tv}"
          CURRENT_TTY=$(cat /sys/class/tty/tty0/active 2>/dev/null || echo "tty1")

          if [ "$CURRENT_TTY" = "tty3" ]; then
              sudo ${pkgs.kbd}/bin/chvt 1
          else
              if [ "$MODE" = "deck" ]; then
                  notify-send -t 2000 "Deck Mode" "Switching to TV (1280x800)..."
              else
                  notify-send -t 2000 "Couch Mode" "Switching to TV (4K)..."
              fi
              echo "$MODE" > "$XDG_RUNTIME_DIR/kernix-couch-mode"
              touch "$XDG_RUNTIME_DIR/kernix-couch-requested"
              systemd-run --user --unit=kernix-couch-transition --collect \
                  kernix-couch-transition
          fi
        '';
      })

      # ── Transition (stop Hyprland, switch to TTY3) ──
      (writeShellApplication {
        name = "kernix-couch-transition";
        runtimeInputs = [procps kbd util-linux];
        text = ''
          # Runs in its own systemd scope (not Hyprland's cgroup).
          # Stops Hyprland, waits for full exit, then switches to TTY3.
          uwsm stop

          while pgrep -x Hyprland >/dev/null 2>&1 || pgrep -x .Hyprland-wrapp >/dev/null 2>&1; do
              sleep 0.2
          done

          pkill -HUP -t tty3 2>/dev/null || true
          sleep 0.5

          sudo ${pkgs.kbd}/bin/chvt 3
        '';
      })

      # ── Steam "Return to Desktop" shim ──
      # Steam's game-mode UI hardcodes `steamos-session-select plasma` for
      # the "Return to Desktop" power-menu action. We just shut down Steam;
      # once Steam exits, steam-gamescope returns, and our cleanup code in
      # kernix-couch-session handles the rest.
      (writeShellApplication {
        name = "steamos-session-select";
        runtimeInputs = [];
        text = ''
          # Argument is always "plasma" from Steam -- we don't care what it is.
          steam -shutdown
        '';
      })

      # ── Session: gamescope + Sunshine on TTY3 ──
      # Reads mode from $XDG_RUNTIME_DIR/kernix-couch-mode to pick resolution:
      #   "tv"   -> 3840x2160 (16:9, TV native)        [default]
      #   "deck" -> 1280x800  (16:10, Steam Deck native)
      (writeShellApplication {
        name = "kernix-couch-session";
        runtimeInputs = [wireplumber procps];
        text = ''
          rm -f "$XDG_RUNTIME_DIR/kernix-couch-requested"
          export XDG_SESSION_TYPE=x11

          MODE_FILE="$XDG_RUNTIME_DIR/kernix-couch-mode"
          MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "tv")

          if [ "$MODE" = "deck" ]; then
              GS_WIDTH=1280
              GS_HEIGHT=800
          else
              GS_WIDTH=3840
              GS_HEIGHT=2160
          fi

          systemctl --user set-environment XDG_DESKTOP_PORTAL_DIR=""
          systemctl --user unset-environment DISPLAY XAUTHORITY

          # ── Audio: switch to TV ──
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

          ulimit -n 524288

          # Start Sunshine for Moonlight streaming
          (sleep 3 && systemctl --user start sunshine.service) &

          # Gamescope session with mode-selected resolution.
          # Env vars and common args from gamescope-defaults.nix (shared with steam.nix).
          ${gsEnvStr} \
          gamescope \
              --steam \
              -O ${tvOutput} \
              -W "$GS_WIDTH" -H "$GS_HEIGHT" \
              -r 60 \
              ${gsArgsStr} \
              -- steam -gamepadui -pipewire-dmabuf \
          || true

          # ── Cleanup: orderly teardown before returning to desktop ──

          # 1. Stop Sunshine first (releases KMS capture handle)
          systemctl --user stop sunshine.service 2>/dev/null || true

          # 2. Wait for gamescope to fully exit and release DRM resources.
          #    Without this, Hyprland can't claim DRM master on TTY1.
          while pgrep -x gamescope >/dev/null 2>&1; do
              sleep 0.2
          done

          # 3. Re-enable desktop portals
          systemctl --user unset-environment XDG_DESKTOP_PORTAL_DIR

          # 4. Restore audio to ultrawide
          wpctl set-profile 52 1 2>/dev/null || true

          # 5. Clean up mode file
          rm -f "$MODE_FILE"

          # 6. Clear UWSM's graphical-session state.
          #    UWSM tracks compositor state via graphical-session*.target.
          #    If these remain active, `uwsm check may-start` returns false
          #    and UWSM refuses to start Hyprland ("compositor already running").
          systemctl --user stop graphical-session.target 2>/dev/null || true
          systemctl --user stop graphical-session-pre.target 2>/dev/null || true

          # 7. Kill stale shell on TTY1 so getty respawns a fresh login.
          #    The fresh login shell triggers UWSM auto-start cleanly.
          pkill -HUP -t tty1 2>/dev/null || true
          sleep 0.5

          # 8. Switch back to TTY1
          sudo ${pkgs.kbd}/bin/chvt 1
        '';
      })
    ];

    programs.zsh.initContent = lib.mkMerge [
      # ── TTY1 guard: clean up stale gamescope before UWSM starts ──
      # Catches the Ctrl+Alt+F1 case: if someone raw-switches to TTY1
      # while gamescope still holds DRM master on TTY3, kill it and wait
      # for DRM release so Hyprland can claim DRM cleanly.
      # Must run before UWSM auto-start (mkOrder 100).
      (lib.mkOrder 45 ''
        if [[ "$(tty)" == "/dev/tty1" ]] && [[ -z "$WAYLAND_DISPLAY" ]] && [[ -z "$DISPLAY" ]]; then
          if ${pkgs.procps}/bin/pgrep -x gamescope >/dev/null 2>&1; then
            systemctl --user stop sunshine.service 2>/dev/null || true
            ${pkgs.procps}/bin/pkill -x gamescope 2>/dev/null || true
            while ${pkgs.procps}/bin/pgrep -x gamescope >/dev/null 2>&1; do
              sleep 0.2
            done
          fi
          # Clear stale UWSM session state so may-start succeeds
          systemctl --user stop graphical-session.target 2>/dev/null || true
          systemctl --user stop graphical-session-pre.target 2>/dev/null || true
        fi
      '')

      # ── TTY3 sentinel: launch gamescope session ──
      # Must run BEFORE the UWSM auto-start (mkOrder 100) to prevent
      # Hyprland from launching on TTY3.
      (lib.mkOrder 50 ''
        if [[ "$(tty)" == "/dev/tty3" ]] && [[ -z "$WAYLAND_DISPLAY" ]] && [[ -z "$DISPLAY" ]]; then
          if [[ -f "$XDG_RUNTIME_DIR/kernix-couch-requested" ]]; then
            exec kernix-couch-session
          fi
        fi
      '')
    ];
  }
