# TradeSkillMaster Desktop -- auction data for WoW Forever.
#
# The package itself lives in overlays/tsm-desktop.nix because it is a
# derivation; this module owns the user-facing install and service wiring.
# The official app installs TradeSkillMaster_AppHelper into `_forever_`, and
# keytar/libsecret needs a Secret Service for "remember me" to survive
# restarts.
#
# Start it via a managed autostart entry instead of the app's own setting:
# the app writes an entry pointing at the extracted Electron binary, which
# NixOS cannot execute (no interpreter). `--hidden` matches the app's own
# startup behaviour and keeps it in the tray.
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

    xdg.configFile."autostart/tsm-desktop.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=TradeSkillMaster Desktop
      Comment=Download auction data for TradeSkillMaster
      Icon=tradeskillmaster
      Exec=${pkgs.tsm-desktop}/bin/tsm-desktop --no-sandbox --hidden
      Terminal=false
      StartupNotify=false
      X-GNOME-Autostart-enabled=true
    '';
  };
}
