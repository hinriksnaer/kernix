# Podman -- system-level only.
# User tools (podman-compose) are managed by Home Manager
# (home/apps/apps.nix).
{
  config,
  lib,
  ...
}:
lib.mkIf (config.kernix.apps.enable && config.kernix.apps.podman.enable) {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  security.unprivilegedUsernsClone = true;

  users.users.${config.kernix.username}.extraGroups = ["podman"];
}
