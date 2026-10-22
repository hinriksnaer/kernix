# kernix - unified configuration manager
#
# Subcommands:
#   rebuild      Rebuild and switch (default)
#   boot         Rebuild for next boot (NixOS only)
#   test         Rebuild and activate without adding to boot menu (NixOS only)
#   update       Update flake inputs and rebuild
#   cleanup [N]  Remove old generations (keep N, default 5)
#   list-gens    List generations
#   container    Manage the dev container (deploy|init|enter [user@host]);
#                no host = local. Same image, unit, and flow everywhere.
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
    container)
        action="${1:-}"
        kx_host="${2:-}"

        if [[ -z "$action" ]]; then
            echo "Usage: kernix container <deploy|init|enter> [user@host]" >&2
            exit 1
        fi
        if ! command -v podman &>/dev/null; then
            echo "Error: podman not found in PATH" >&2
            exit 1
        fi

        # Run a command on the target host; empty host = local.
        kx_run() {
            if [[ -n "$kx_host" ]]; then
                ssh "$kx_host" "$@"
            else
                "$@"
            fi
        }

        # Run a bash script inside the container. Base64 keeps the
        # script intact through local quoting, ssh re-parsing, and
        # podman exec alike.
        kx_exec() {
            if [[ -n "$kx_host" ]]; then
                local encoded
                encoded=$(printf '%s' "$1" | base64 -w0)
                ssh "$kx_host" "echo $encoded | base64 -d | podman exec -i kernix-dev bash -s"
            else
                printf '%s' "$1" | podman exec -i kernix-dev bash -s
            fi
        }

        case "$action" in
            deploy)
                echo "==> Deploying kernix-dev${kx_host:+ to $kx_host}"
                tmp=$(mktemp -d)
                trap 'rm -rf "$tmp"' EXIT
                echo ":: building image + unit from $KERNIX_ROOT"
                nix build --out-link "$tmp/image" "$KERNIX_ROOT#container-image"
                nix build --out-link "$tmp/unit" "$KERNIX_ROOT#container-quadlet"
                echo ":: loading image"
                kx_run podman load < "$tmp/image"
                echo ":: installing quadlet unit"
                if [[ -n "$kx_host" ]]; then
                    ssh "$kx_host" mkdir -p .config/containers/systemd
                    # rm first: scp cannot overwrite the read-only mode
                    # inherited from the nix store source.
                    ssh "$kx_host" rm -f .config/containers/systemd/kernix-dev.container
                    scp "$tmp/unit" "$kx_host:.config/containers/systemd/kernix-dev.container"
                    ssh "$kx_host" loginctl enable-linger || \
                        echo "Note: lingering off; container starts at first login instead"
                else
                    mkdir -p "$HOME/.config/containers/systemd"
                    # install (not cp): the store source is mode 444, which
                    # cp would propagate and break later overwrites.
                    install -m 0644 "$tmp/unit" "$HOME/.config/containers/systemd/kernix-dev.container"
                fi
                kx_run systemctl --user daemon-reload
                # Replace any pre-systemd container; volumes persist.
                kx_run podman rm -f kernix-dev >/dev/null 2>&1 || true
                # Boot-start comes from the unit's [Install] section -- the
                # quadlet generator wires default.target.wants itself
                # (systemctl enable can't handle generated units).
                kx_run systemctl --user restart kernix-dev.service
                echo ":: done -- systemctl --user status kernix-dev"
                echo "   first run? kernix container init${kx_host:+ $kx_host}"
                ;;
            init)
                echo "==> Initializing kernix-dev${kx_host:+ on $kx_host}"
                repo_url=$(git -C "$KERNIX_ROOT" remote get-url origin)
                if ! kx_exec '[ -f ~/.ssh/id_ed25519 ]'; then
                    kx_exec 'mkdir -p ~/.ssh && chmod 700 ~/.ssh
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519 -C kernix-dev >/dev/null'
                    echo ":: generated deploy key -- add it as a READ-ONLY deploy key:"
                    echo "   https://github.com/hinriksnaer/kernix/settings/keys"
                    kx_exec 'cat ~/.ssh/id_ed25519.pub'
                    if [[ -t 0 ]]; then
                        read -r -p ":: press enter once the key is added " _
                    else
                        echo ":: (no tty) add the key, then re-run: kernix container init${kx_host:+ $kx_host}"
                    fi
                fi
                kx_exec "GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=accept-new' \
[ -d ~/kernix ] || git clone --recurse-submodules $repo_url ~/kernix"
                # Free the baked bootstrap profile link for home-manager to own
                # (otherwise git-minimal from the image collides with the profile).
                # One level of readlink: -f resolves through to the store
                # path and would never match the baked bootstrap link.
                kx_exec '[ "$(readlink ~/.nix-profile)" = /nix/var/nix/profiles/default ] && rm ~/.nix-profile || true'
                kx_exec 'home-manager switch --flake ~/kernix#dev@container -b backup'
                echo ":: done -- jump in with: kernix container enter${kx_host:+ $kx_host}"
                ;;
            enter)
                if [[ -n "$kx_host" ]]; then
                    exec ssh -t "$kx_host" podman exec -it -w /home/dev kernix-dev zsh -l
                else
                    podman exec -it -w /home/dev kernix-dev zsh -l || podman exec -it -w /home/dev kernix-dev bash -l
                fi
                ;;
            *)
                echo "Error: unknown container action '$action'" >&2
                echo "Usage: kernix container <deploy|init|enter> [user@host]" >&2
                exit 1
                ;;
        esac
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
        echo "  container    Dev container: deploy, init, enter (optional user@host)"
        echo ""
        echo "Extra options are forwarded to the underlying tool."
        ;;
    *)
        echo "Error: unknown command '${subcmd}'" >&2
        echo "Run 'kernix help' for usage" >&2
        exit 1
        ;;
esac
