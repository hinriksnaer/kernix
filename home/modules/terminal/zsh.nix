# Zsh -- fully managed by Home Manager.
# Shell integrations for starship, fzf, zoxide, lsd are handled
# automatically by their respective HM modules in cli-tools.nix.
{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    # Nix profile paths for non-NixOS hosts
    envExtra = ''
      if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
      if [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
      fi
    '';

    initContent = lib.mkMerge [
      # Terminfo from HM profile (kitty terminfo for SSH sessions)
      (lib.mkOrder 600 ''
        if [ -d "$HOME/.nix-profile/share/terminfo" ]; then
          export TERMINFO_DIRS="$HOME/.nix-profile/share/terminfo:''${TERMINFO_DIRS:-}"
        fi
      '')
    ];

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };

    shellAliases = {
      y = "yazi";
    };
  };

  # Enable bash for non-NixOS hosts that default to it
  programs.bash.enable = true;
}
