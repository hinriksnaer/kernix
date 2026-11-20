# TradeSkillMaster Desktop -- auction data for WoW Forever.
#
# The package itself lives in overlays/tsm-desktop.nix because it is a
# derivation; this module owns the user-facing install and service wiring.
# The official app installs TradeSkillMaster_AppHelper into `_forever_`, and
# keytar/libsecret needs a Secret Service for "remember me" to survive
# restarts.
#
# Deliberately *not* autostarted. The window content is a remote OIDC page
# (id.tradeskillmaster.com), and main.js installs no did-fail-load retry: when
# the entry fired at login it raced Wi-Fi association (which finished ~2s
# later), the page load failed, and the renderer stayed blank forever. Worse,
# the dead instance holds Electron's singleton lock, so every later launch
# (rofi, desktop entry, tray) only re-focuses the blank window instead of
# starting a working one. Launch it on demand instead -- the app only matters
# while playing anyway -- after which `--hidden` keeps it in the tray.
{
  lib,
  pkgs,
  host,
  ...
}: {
  config = lib.mkIf host.gaming.enable {
    home.packages = [pkgs.tsm-desktop];

    services.gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
  };
}
