#!/usr/bin/env bash
# One-time cleanup: remove /etc symlinks left by the broken system-manager activation.
# Run as: sudo bash hosts/fedora/cleanup-system-manager.sh
set -euo pipefail

echo ":: removing system-manager /etc leftovers"

# /etc files
rm -f \
  /etc/fonts/local.conf \
  /etc/profile.d/system-manager-path.sh \
  /etc/environment.d/10-system-manager.conf \
  /etc/tmpfiles.d/00-system-manager.conf \
  /etc/tmpfiles.d/home-directories.conf

# systemd unit symlinks
rm -f \
  /etc/systemd/system/run-wrappers.mount \
  /etc/systemd/system/suid-sgid-wrappers.service \
  /etc/systemd/system/sysinit-reactivation.target \
  /etc/systemd/system/system-manager-path.service \
  /etc/systemd/system/system-manager.target \
  /etc/systemd/system/userborn-import-legacy.service \
  /etc/systemd/system/userborn.service

# systemd dependency dirs
rm -rf \
  /etc/systemd/system/sysinit-reactivation.target.requires \
  /etc/systemd/system/system-manager.target.wants \
  /etc/systemd/system/userborn.service.requires

# reload systemd so it forgets the removed units
systemctl daemon-reload

# nix-collect-garbage removes the now-unused system-manager store paths
echo ":: done -- run 'nix-collect-garbage' to free store space"
