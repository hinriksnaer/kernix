# Thunar -- system-level only (gvfs for trash/mounts).
# The thunar package itself is managed by Home Manager
# (home/apps/apps.nix).
{...}: {
  services.gvfs.enable = true;
}
