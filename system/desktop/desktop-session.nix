# Desktop session -- system-level only.
# User-level parts (packages, cursor, dconf settings, session variables)
# are managed by Home Manager (home/desktop/session.nix).
{
  config,
  lib,
  ...
}:
lib.mkIf config.kernix.desktop.enable {
  security.polkit.enable = true;

  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = "99";
    }
    {
      domain = "@users";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
    {
      # Allow Proton/game processes to raise their scheduling priority.
      domain = "*";
      item = "nice";
      type = "hard";
      value = "-8";
    }
  ];

  programs.dconf.enable = true;
}
