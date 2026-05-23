# Desktop session -- system-level only.
# User-level parts (packages, cursor, dconf settings, session variables)
# are managed by Home Manager (home/desktop/session.nix).
{...}: {
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
  ];

  programs.dconf.enable = true;
}
