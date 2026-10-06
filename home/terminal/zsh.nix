# Zsh -- fully managed by Home Manager.
# Shell integrations for starship, fzf, zoxide, lsd are handled
# automatically by their respective HM modules in cli-tools.nix.
{
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    autosuggestion.strategy = ["history" "completion"];
    historySubstringSearch.enable = true;
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
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
      # Refresh SSH_AUTH_SOCK on every shell so herdr panes inherit the live
      # Bitwarden agent socket rather than the stale value the herdr server
      # captured at startup.
      (lib.mkOrder 400 ''
        _bw_sock="$HOME/.bitwarden-ssh-agent.sock"
        if [ -S "$_bw_sock" ]; then
          export SSH_AUTH_SOCK="$_bw_sock"
        fi
        unset _bw_sock
      '')

      # zsh-vi-mode config (must be set before plugin loads)
      (lib.mkOrder 500 ''
        ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
        ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK

        # Re-source fzf keybindings after zsh-vi-mode steals them
        zvm_after_init_commands+=('source <(fzf --zsh)')
      '')

      # Use base16 theme for fast-syntax-highlighting (inherits terminal ANSI colors)
      (lib.mkOrder 600 ''
        fast-theme base16 >/dev/null 2>&1 || true
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
