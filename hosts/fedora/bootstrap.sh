#!/usr/bin/env bash
# First-time setup for Fedora CSB + Nix.
# Run as your normal user. The script will prompt for sudo only when
# a specific command requires root.
#
# Prerequisites: dnf install nix && reboot (or re-login for nix group)
# Usage: bash hosts/fedora/bootstrap.sh

set -euo pipefail

KERNIX_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HM_PROFILE="hgudmund@fedora"

echo "==> kernix: fedora bootstrap"
echo "    root: $KERNIX_ROOT"

# ── Preflight: verify nix daemon is running ──
if ! systemctl is-active --quiet nix-daemon; then
    echo "error: nix-daemon is not running."
    echo "run:   sudo systemctl enable --now nix-daemon"
    echo "then:  re-login (for nix group membership) and re-run this script."
    exit 1
fi

# ── 1. Enable flakes ──
mkdir -p "$HOME/.config/nix"
grep -q 'experimental-features' "$HOME/.config/nix/nix.conf" 2>/dev/null || {
    echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"
    echo ":: enabled flakes"
}

# ── 2. Home Manager (user-level, no sudo) ──
echo ":: applying home-manager ($HM_PROFILE)"
nix run home-manager/master -- switch --flake "$KERNIX_ROOT#$HM_PROFILE"

# ── 3. GPU drivers (sudo: creates /run/opengl-driver symlink) ──
HM_BIN="$HOME/.local/state/nix/profiles/home-manager/home-path/bin"
if [ ! -L /run/opengl-driver ]; then
    echo ":: setting up GPU drivers"
    sudo "$HM_BIN/non-nixos-gpu-setup"
else
    echo ":: GPU drivers already configured"
fi

# ── 4. Login shell (sudo: chsh modifies /etc/passwd) ──
ZSH="$HM_BIN/zsh"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH" ]; then
    echo ":: switching login shell to zsh"
    chsh -s "$ZSH"
fi

echo ""
echo "==> done -- log out and back in on TTY1 to start Hyprland"
