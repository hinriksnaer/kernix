# Thunar -- system-level only (gvfs for trash/mounts).
# The thunar package itself is managed by Home Manager
# (home/modules/apps/apps.nix).
{ ... }:

{
  services.gvfs.enable = true;
}
