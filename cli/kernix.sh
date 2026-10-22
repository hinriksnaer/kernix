# kernix - unified configuration manager
#
# Subcommands:
#   rebuild      Rebuild and switch (default)
#   boot         Rebuild for next boot (NixOS only)
#   test         Rebuild and activate without adding to boot menu (NixOS only)
#   update       Update flake inputs and rebuild
#   cleanup [N]  Remove old generations (keep N, default 5)
#   list-gens    List generations
#
# Extra arguments are forwarded to the underlying tool.
# Notifications are sent when the terminal loses focus during a build.
#
# Variables injected by Nix (prepended to this script):
#   HOST_TYPE   - "nixos" or "hm"
#   HM_PROFILE  - homeConfigurations key (e.g. "hgudmund@remote"), empty on NixOS
#   KERNIX_ROOT - path to the kernix repo

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
                notify-send -u critical "kernix" \
                    "${cmd_label} failed after ${duration_fmt}" -t 10000
            else
                notify-send -u normal "kernix" \
                    "${cmd_label} succeeded in ${duration_fmt}" -t 5000
            fi
        fi
    fi

    return $exit_code
}

# ── NixOS: derive config name from hostname ──
CONF=""
if [[ "$HOST_TYPE" == "nixos" ]]; then
    HOST=$(hostname)
    if [[ "${HOST}" == kernix-* ]]; then
        CONF="${HOST#kernix-}"
    else
        echo "Error: hostname '${HOST}' doesn't match kernix-<config> pattern" >&2
        echo "Expected a hostname like 'kernix-desktop' or 'kernix-laptop'" >&2
        exit 1
    fi
fi

# ── HM: pull latest before rebuild ──
hm_pull() {
    echo ":: pulling latest config"
    git -C "$KERNIX_ROOT" pull --ff-only
}

# ── Subcommands ──
subcmd="${1:-rebuild}"
shift 2>/dev/null || true

case "$subcmd" in
    rebuild)
        if [[ "$HOST_TYPE" == "nixos" ]]; then
            echo "==> Rebuilding ${HOST} (${CONF})..."
            run_with_notify "rebuild" nh os switch --hostname "${CONF}" "$@"
        else
            hm_pull
            echo ":: applying Home Manager (${HM_PROFILE})"
            run_with_notify "rebuild" home-manager switch --flake "$KERNIX_ROOT#${HM_PROFILE}" "$@"
        fi
        ;;
    boot)
        if [[ "$HOST_TYPE" != "nixos" ]]; then
            echo "Error: 'boot' is only supported on NixOS hosts" >&2
            exit 1
        fi
        echo "==> Rebuilding ${HOST} (${CONF}) for next boot..."
        run_with_notify "rebuild-boot" nh os boot --hostname "${CONF}" "$@"
        ;;
    test)
        if [[ "$HOST_TYPE" != "nixos" ]]; then
            echo "Error: 'test' is only supported on NixOS hosts" >&2
            exit 1
        fi
        echo "==> Test-activating ${HOST} (${CONF})..."
        run_with_notify "test" nh os test --hostname "${CONF}" "$@"
        ;;
    update)
        if [[ "$HOST_TYPE" == "nixos" ]]; then
            echo "==> Updating flake inputs and rebuilding ${HOST} (${CONF})..."
            run_with_notify "update" nh os switch --hostname "${CONF}" --update "$@"
        else
            hm_pull
            echo ":: updating flake inputs"
            nix flake update --flake "$KERNIX_ROOT"
            echo ":: applying Home Manager (${HM_PROFILE})"
            run_with_notify "update" home-manager switch --flake "$KERNIX_ROOT#${HM_PROFILE}" "$@"
        fi
        ;;
    cleanup)
        keep="${1:-5}"
        if [[ "$HOST_TYPE" == "nixos" ]]; then
            echo "==> Cleaning up old generations (keeping ${keep})..."
            nh clean all --keep "$keep"
        else
            echo "==> Cleaning up old Home Manager generations (keeping ${keep})..."
            home-manager expire-generations "-${keep} days" 2>/dev/null || \
                echo "Note: expire-generations removes profiles older than ${keep} days"
        fi
        ;;
    list-gens)
        if [[ "$HOST_TYPE" == "nixos" ]]; then
            echo "==> System generations:"
            nix profile history --profile /nix/var/nix/profiles/system
        else
            echo "==> Home Manager generations:"
            home-manager generations
        fi
        ;;
    -h|--help|help)
        echo "Usage: kernix [command] [options]"
        echo ""
        echo "Commands:"
        echo "  rebuild      Rebuild and switch (default)"
        if [[ "$HOST_TYPE" == "nixos" ]]; then
            echo "  boot         Rebuild for next boot"
            echo "  test         Activate without adding to boot menu"
        fi
        echo "  update       Update flake inputs + rebuild"
        echo "  cleanup [N]  Remove old generations (keep N, default 5)"
        echo "  list-gens    List generations"
        echo ""
        echo "Extra options are forwarded to the underlying tool."
        ;;
    *)
        echo "Error: unknown command '${subcmd}'" >&2
        echo "Run 'kernix help' for usage" >&2
        exit 1
        ;;
esac
