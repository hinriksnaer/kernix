# Central CLI packaging. All scripts use writeShellApplication for
# consistent shellcheck validation, set -euo pipefail, and runtimeInputs.
#
# hmProfile: the homeConfigurations key (e.g. "hgudmund@remote").
#            Required for kernix-hm-switch and kernix-fedora-switch.
# darwinHost: the darwinConfigurations key (e.g. "macbook").
#             Required for kernix-darwin-switch. Pass null when not needed.
{
  pkgs,
  hmProfile ? null,
  darwinHost ? null,
}: {
  # NixOS hosts: rebuild with subcommands (rebuild/boot/test/update/cleanup/list-gens)
  kernix = pkgs.writeShellApplication {
    name = "kernix";
    runtimeInputs = with pkgs; [coreutils hostname jq libnotify nh nix];
    text = builtins.readFile ./kernix.sh;
    excludeShellChecks = ["SC2086" "SC2229"];
  };

  # Non-NixOS hosts: git pull + home-manager switch
  kernix-hm-switch = assert hmProfile != null;
    pkgs.writeShellApplication {
      name = "kernix-hm-switch";
      runtimeInputs = with pkgs; [git nix];
      text = ''
        KERNIX_ROOT="''${KERNIX_ROOT:-''${SETTINGS_DIR:-$HOME/kernix}}"
        echo ":: pulling latest config"
        git -C "$KERNIX_ROOT" pull --ff-only
        echo ":: updating flake inputs"
        nix flake update --flake "$KERNIX_ROOT"
        echo ":: applying Home Manager (${hmProfile})"
        home-manager switch --flake "$KERNIX_ROOT#${hmProfile}" "$@"
        echo ":: done — run 'direnv reload' to pick up devshell changes"
      '';
    };

  # Darwin hosts: git pull + nh darwin switch
  kernix-darwin-switch = assert darwinHost != null;
    pkgs.writeShellApplication {
      name = "kernix-darwin-switch";
      runtimeInputs = with pkgs; [git nix nh];
      text = ''
        KERNIX_ROOT="''${KERNIX_ROOT:-$HOME/kernix}"
        echo ":: pulling latest config"
        git -C "$KERNIX_ROOT" pull --ff-only
        echo ":: rebuilding darwin (${darwinHost})"
        nh darwin switch "$KERNIX_ROOT" --hostname "${darwinHost}" "$@"
        echo ":: done"
      '';
    };

  # Fedora hosts: git pull + home-manager switch
  kernix-fedora-switch = assert hmProfile != null;
    pkgs.writeShellApplication {
      name = "kernix-fedora-switch";
      runtimeInputs = with pkgs; [git nix];
      text = ''
        KERNIX_ROOT="''${KERNIX_ROOT:-$HOME/kernix}"
        echo ":: pulling latest config"
        git -C "$KERNIX_ROOT" pull --ff-only
        echo ":: updating flake inputs"
        nix flake update --flake "$KERNIX_ROOT"
        echo ":: applying Home Manager (${hmProfile})"
        home-manager switch --flake "$KERNIX_ROOT#${hmProfile}" "$@"
        echo ":: done"
      '';
    };
}
