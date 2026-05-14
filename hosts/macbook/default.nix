# macOS (nix-darwin) host configuration.
# Apply with: sudo darwin-rebuild switch --flake ~/kernix#macbook
{settings, ...}: {
  # ── Nix settings ──
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ── Primary user (required by nix-darwin for root activation) ──
  system.primaryUser = settings.hosts.macbook.username;

  # ── User (home directory must be declared for home-manager integration) ──
  users.users.${settings.hosts.macbook.username}.home = "/Users/${settings.hosts.macbook.username}";

  # ── Zsh (disable system compinit -- HM handles it with -u for Nix dirs) ──
  programs.zsh.enableCompletion = false;

  # ── Locale (required for proper UTF-8 / Nerd Font rendering) ──
  environment.variables.LANG = "en_US.UTF-8";
  environment.variables.LC_ALL = "en_US.UTF-8";

  # ── Homebrew (packages not in nixpkgs for darwin) ──
  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "font-jetbrains-mono-nerd-font"
    ];
    onActivation.cleanup = "zap";
  };

  # ── Required by nix-darwin ──
  system.stateVersion = 6;
}
