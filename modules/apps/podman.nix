# Podman -- system-level only.
# User tools (podman-compose) are managed by Home Manager
# (home/modules/apps/apps.nix).
{config, ...}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  security.unprivilegedUsernsClone = true;

  users.users.${config.kernix.username}.extraGroups = ["podman"];
}
