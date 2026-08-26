#!/usr/bin/env bash
# First-time setup for Fedora CSB + Nix.
# Handles only what Nix cannot manage for itself:
#   0. Nix daemon (Fedora multi-user install requires it)
#   1. Enabling flakes (chicken-and-egg for first home-manager switch)
#   2. Initial home-manager apply
#   3. GPU driver symlink (requires root)
#   4. System-manager apply (requires root)
#   5. Login shell switch to zsh
#
# Prerequisites: dnf install nix
# Usage: bash hosts/fedora/bootstrap.sh

set -euo pipefail

KERNIX_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
HM_PROFILE="hgudmund@fedora"
SM_CONFIG="fedora"

echo "==> kernix: fedora bootstrap"
echo "    root: $KERNIX_ROOT"

# ── 0. Ensure nix daemon is running ──
# Fedora's multi-user Nix install requires the daemon for store access.
# Without it, user-level nix commands hit /nix/store/.links permission errors.
if ! systemctl is-active --quiet nix-daemon; then
    echo ":: enabling nix daemon"
    sudo systemctl enable --now nix-daemon
fi

# ── 1. Enable flakes ──
mkdir -p "$HOME/.config/nix"
grep -q 'experimental-features' "$HOME/.config/nix/nix.conf" 2>/dev/null || {
    echo 'experimental-features = nix-command flakes' >> "$HOME/.config/nix/nix.conf"
    echo ":: enabled flakes"
}

# ── 2. Home Manager ──
echo ":: applying home-manager ($HM_PROFILE)"
nix run home-manager/master -- switch --flake "$KERNIX_ROOT#$HM_PROFILE"

# ── 3. GPU drivers ──
HM_BIN="$HOME/.local/state/nix/profiles/home-manager/home-path/bin"
if [ ! -L /run/opengl-driver ]; then
    echo ":: setting up GPU drivers (requires sudo)"
    sudo "$HM_BIN/non-nixos-gpu-setup"
else
    echo ":: GPU drivers already configured"
fi

# ── 4. System-manager (fonts) ──
echo ":: applying system-manager ($SM_CONFIG)"
nix run 'github:numtide/system-manager' -- switch --flake "$KERNIX_ROOT#$SM_CONFIG" --sudo

# ── 5. Login shell ──
ZSH="$HM_BIN/zsh"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH" ]; then
    echo ":: switching login shell to zsh"
    chsh -s "$ZSH"
fi

echo ""
echo "==> done -- log out and back in on TTY1 to start Hyprland"
