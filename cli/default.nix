# Central CLI packaging. All scripts use writeShellApplication for
# consistent shellcheck validation, set -euo pipefail, and runtimeInputs.
#
# hmProfile: the homeConfigurations key (e.g. "hgudmund@remote").
#            Required for kernix-hm-switch. Pass null when not needed.
{ pkgs, hmProfile ? null }:

{
  # NixOS hosts: rebuild with subcommands (rebuild/boot/test/update/cleanup/list-gens)
  kernix = pkgs.writeShellApplication {
    name = "kernix";
    runtimeInputs = with pkgs; [ coreutils hostname jq libnotify nh nix ];
    text = builtins.readFile ./kernix.sh;
    excludeShellChecks = [ "SC2086" "SC2229" ];
  };

  # Non-NixOS hosts: git pull + home-manager switch
  kernix-hm-switch = assert hmProfile != null;
    pkgs.writeShellApplication {
      name = "kernix-hm-switch";
      runtimeInputs = with pkgs; [ git ];
      text = ''
        KERNIX_ROOT="''${KERNIX_ROOT:-$HOME/kernix}"
        echo ":: pulling latest config"
        git -C "$KERNIX_ROOT" pull --ff-only
        echo ":: applying Home Manager (${hmProfile})"
        home-manager switch --flake "$KERNIX_ROOT#${hmProfile}" "$@"
        echo ":: done — run 'direnv reload' to pick up devshell changes"
      '';
    };

  # Devshell: project setup/build/status/update/clean
  kernix-dev = pkgs.writeShellApplication {
    name = "kernix-dev";
    text = builtins.readFile ./kernix-dev.sh;
    excludeShellChecks = [ "SC1091" "SC2086" "SC2155" ];
  };
}
