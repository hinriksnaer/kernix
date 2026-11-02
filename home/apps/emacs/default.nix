# Doom Emacs -- emacs + framework + config, all deployed from the Nix store.
#
# Three pieces, mirroring how neovim is handled:
#   - emacs + external deps  -> nixpkgs
#   - doomemacs flake input  -> the Doom framework, pinned by flake.lock and
#                               symlinked into ~/.config/emacs/ (read-only)
#   - ./doom/                -> your Doom config, symlinked into
#                               ~/.config/doom/ (read-only)
#
# Same architecture as sebnyberg/doomemacs-nix-example and friends, with the
# framework source provisioned as a pinned flake input instead of fetchGit:
#   nix flake update doomemacs
#
# Doom's build state (straight.el packages, caches) is redirected to
# DOOMLOCALDIR (~/.config/doom-local) because the store links are
# read-only. The only command ever needed after a rebuild is:
#   doom sync
#
# `doom upgrade` and `doom env` do not work (they write into read-only
# paths); Nix provides the environment, and framework updates come from
# the flake input.
{
  pkgs,
  lib,
  config,
  host,
  doomemacs,
  ...
}:
lib.mkIf (host.apps.enable && host.apps.emacs) {
  home.packages = with pkgs; [
    emacs

    # Doom dependencies
    git
    ripgrep
    gnutls # TLS connectivity
    fd # faster projectile indexing

    # Module dependencies
    zstd # undo-fu-session/undo-tree compression
    sqlite # :tools lookup & :lang org
    editorconfig-core-c # :tools editorconfig
    (aspellWithDicts (ds: with ds; [en])) # :checkers spell

    # :lang cc / :tools lsp
    clang-tools

    # :tools debugger (dape) -- debugpy is not importable by plain python3
    # on nix, so provide a wrapper that injects the site-packages path.
    # The dape config override in doom/config.el points `command' at it.
    (pkgs.writeShellScriptBin "dape-python" ''
      export PYTHONPATH="${pkgs.python3Packages.debugpy}/${pkgs.python3.sitePackages}''${PYTHONPATH:+:$PYTHONPATH}"
      exec ${pkgs.python3}/bin/python3 "$@"
    '')
  ];

  # Make the doom CLI (~/.config/emacs/bin/doom) available from any shell.
  # sessionPath makes it visible to both shells and the systemd user
  # environment, so GUI-launched Emacs sees it too.
  home.sessionPath = ["${config.xdg.configHome}/emacs/bin"];

  # Env vars must come from outside Doom: DOOMDIR is resolved before any
  # config.el runs, and DOOMLOCALDIR is consumed by the doom CLI during
  # bootstrap. DOOMLOCALDIR points at a writable location because the
  # store-linked config dirs are read-only.
  home.sessionVariables = {
    DOOMDIR = "${config.xdg.configHome}/doom";
    DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
  };

  xdg.configFile = {
    "emacs".source = doomemacs;
    # Doom config symlinked directly at the kernix repo (not via the Nix
    # store) so config.el/init.el edits are picked up without a rebuild.
    # Trade-off: the deployed config is the working tree, not what is
    # committed -- rebuilds no longer capture doom config changes.
    "doom".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/kernix/home/apps/emacs/doom";
  };
}
