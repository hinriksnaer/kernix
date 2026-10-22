{lib, ...}: {
  options.kernix.apps = {
    enable = lib.mkEnableOption "GUI applications";

    vscodeFhs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Ship VS Code as the FHS (bwrap) build with openssh baked in.

        Required on NixOS: the chroot hides the host's /usr, so Remote-SSH
        cannot find ssh otherwise, and marketplace extensions that ship
        prebuilt binaries need the FHS environment.

        Set to false on foreign distros. There the chroot also hides
        /usr/lib64, and the baked-in nix openssh cannot resolve sssd/LDAP
        uids -- it has no /etc/passwd entry and the nix glibc cannot load
        libnss_sss, so `ssh -V` fatals with "No user exists for uid <uid>"
        (exit 255) and Remote-SSH reports "ssh is not on the PATH". Plain
        VS Code inherits the host PATH and uses the system ssh instead.
      '';
    };
  };
}
