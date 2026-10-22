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
      runtimeInputs = with pkgs;
        [coreutils git nix openssh]
        ++ lib.optionals (hostType == "nixos") [hostname jq libnotify nh];
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
      # SC2016/SC2029: the container subcommand's ssh/base64 patterns
      # deliberately expand (or deliberately don't) on the client side.
      excludeShellChecks = ["SC2016" "SC2029" "SC2086" "SC2229"];
    };
}
