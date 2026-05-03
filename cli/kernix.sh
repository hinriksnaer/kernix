# kernix - manage NixOS configuration rebuilds
#
# Subcommands:
#   rebuild      Rebuild and switch (default)
#   boot         Rebuild for next boot (safer for DM/session changes)
#   test         Rebuild and activate without adding to boot menu
#   update       Update flake inputs and rebuild
#   cleanup [N]  Remove old generations (keep N, default 5)
#   list-gens    List system generations
#
# Extra arguments are forwarded to nh.
# Notifications are sent when the terminal loses focus during a build.

HOST=$(hostname)

# Map hostname -> flake configuration name
case "${HOST}" in
    kernix-desktop) CONF="desktop" ;;
    kernix-laptop)  CONF="laptop"  ;;
    *)
        echo "Error: unknown host '${HOST}'" >&2
        echo "Add a mapping in kernix.sh" >&2
        exit 1
        ;;
esac

# ── Notification wrapper ──
# Tracks hyprland window focus. Only notifies if user switched away.
run_with_notify() {
    local cmd_label="$1"
    shift

    # Capture originating window (skip if hyprctl unavailable)
    local origin_addr=""
    if command -v hyprctl &>/dev/null; then
        origin_addr=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty' 2>/dev/null) || true
    fi

    local start_time
    start_time=$(date +%s)

    # Run the actual command
    local exit_code=0
    "$@" || exit_code=$?

    local end_time
    end_time=$(date +%s)
    local duration=$(( end_time - start_time ))
    local duration_fmt
    duration_fmt="$(( duration / 60 ))m $(printf "%02d" $(( duration % 60 )))s"

    # Only notify if we have hyprctl and user switched away
    if [[ -n "$origin_addr" ]] && command -v notify-send &>/dev/null; then
        local current_addr
        current_addr=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty' 2>/dev/null) || true

        if [[ "$current_addr" != "$origin_addr" ]]; then
            if [[ $exit_code -ne 0 ]]; then
                notify-send -u critical "kernix-switch" \
                    "${cmd_label} failed after ${duration_fmt}" -t 10000
            else
                notify-send -u normal "kernix-switch" \
                    "${cmd_label} succeeded in ${duration_fmt}" -t 5000
            fi
        fi
    fi

    return $exit_code
}

# ── Subcommands ──
subcmd="${1:-rebuild}"
shift 2>/dev/null || true

case "$subcmd" in
    rebuild)
        echo "==> Rebuilding ${HOST} (${CONF})..."
        run_with_notify "rebuild" nh os switch --hostname "${CONF}" "$@"
        ;;
    boot)
        echo "==> Rebuilding ${HOST} (${CONF}) for next boot..."
        run_with_notify "rebuild-boot" nh os boot --hostname "${CONF}" "$@"
        ;;
    test)
        echo "==> Test-activating ${HOST} (${CONF})..."
        run_with_notify "test" nh os test --hostname "${CONF}" "$@"
        ;;
    update)
        echo "==> Updating flake inputs and rebuilding ${HOST} (${CONF})..."
        run_with_notify "update" nh os switch --hostname "${CONF}" --update "$@"
        ;;
    cleanup)
        keep="${1:-5}"
        echo "==> Cleaning up old generations (keeping ${keep})..."
        nh clean all --keep "$keep"
        ;;
    list-gens)
        echo "==> System generations:"
        nix profile history --profile /nix/var/nix/profiles/system
        ;;
    -h|--help|help)
        echo "Usage: kernix-switch [command] [options]"
        echo ""
        echo "Commands:"
        echo "  rebuild      Rebuild and switch (default)"
        echo "  boot         Rebuild for next boot"
        echo "  test         Activate without adding to boot menu"
        echo "  update       Update flake inputs + rebuild"
        echo "  cleanup [N]  Remove old generations (keep N, default 5)"
        echo "  list-gens    List system generations"
        echo ""
        echo "Extra options are forwarded to nh."
        ;;
    *)
        echo "Error: unknown command '${subcmd}'" >&2
        echo "Run 'kernix-switch help' for usage" >&2
        exit 1
        ;;
esac
