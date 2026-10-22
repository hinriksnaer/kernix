# Home Manager entry point.
# Receives hostname from flake.nix. The host config attrset is passed
# via extraSpecialArgs and available to all modules as the `host` arg.
{hostname}: {
  host,
  lib,
  ...
}: let
  username = host.username;
  homePrefix = host.homePrefix;
  homeDirectory =
    if username == "root"
    then "/root"
    else "${homePrefix}/${username}";
in {
  imports =
    [
      # All modules imported -- leaf modules gate themselves via lib.mkIf host.*
      ./terminal
      ./desktop
      ./apps
      ./agents
      ./gaming
      ./nixtorch.nix
      ./theme
    ]
    ++ lib.optional (builtins.pathExists ../hosts/${hostname}/home.nix)
    ../hosts/${hostname}/home.nix;

  programs.home-manager.enable = true;

  # ── Common user identity ──
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.11";

  # Expose username to scripts/dotfiles at runtime
  home.sessionVariables.KERNIX_USER = username;
  home.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  # Containers and bare SSH sessions have no logind, so XDG_RUNTIME_DIR is
  # unset -- and anything wanting a runtime dir (rbw's ssh-agent socket, tmux,
  # the gaming scripts) then breaks or writes to an empty path. Fall back to a
  # per-user dir we own and create it. On hosts with logind the variable is
  # already set, so this expands to itself and nothing changes.
  home.sessionVariables.XDG_RUNTIME_DIR = "\${XDG_RUNTIME_DIR:-$HOME/.run}";
  home.activation.createRuntimeDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "$HOME/.run"
    run chmod 700 "$HOME/.run"
  '';
}
