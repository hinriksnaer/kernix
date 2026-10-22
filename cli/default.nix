# Central CLI packaging. All scripts use writeShellApplication for
# consistent shellcheck validation, set -euo pipefail, and runtimeInputs.
#
# hostType: "nixos" (default) or "hm" (standalone Home Manager).
# hmProfile: the homeConfigurations key (e.g. "hgudmund@remote").
#            Required when hostType is "hm".
{
  pkgs,
  hostType ? "nixos",
  hmProfile ? null,
}: {
  kernix = assert hostType == "nixos" || hmProfile != null;
    pkgs.writeShellApplication {
      name = "kernix";
      runtimeInputs =
        (with pkgs;
          # No openssh: the nix ssh's glibc cannot resolve sssd/LDAP
          # uids on foreign distros, breaking git auth for domain users.
          # Hosts running kernix have system ssh (they cloned the repo
          # with it).
          [coreutils git nix]
          ++ lib.optionals (hostType == "nixos") [hostname jq libnotify nh]);
      text =
        ''
          HOST_TYPE="${hostType}"
          HM_PROFILE="${
            if hmProfile != null
            then hmProfile
            else ""
          }"
          KERNIX_ROOT="''${KERNIX_ROOT:-''${SETTINGS_DIR:-$HOME/kernix}}"
        ''
        + builtins.readFile ./kernix.sh;
      # SC2086/SC2229: legacy patterns kept for safety.
      excludeShellChecks = ["SC2016" "SC2029" "SC2086" "SC2229"];
    };
}
