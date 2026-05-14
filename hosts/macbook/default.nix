# macOS (nix-darwin) host configuration.
# Apply with: sudo darwin-rebuild switch --flake ~/kernix#macbook
{settings, ...}: {
  # ── Nix settings ──
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ── Primary user (required by nix-darwin for root activation) ──
  system.primaryUser = settings.hosts.macbook.username;

  # ── User (home directory must be declared for home-manager integration) ──
  users.users.${settings.hosts.macbook.username}.home = "/Users/${settings.hosts.macbook.username}";

  # ── Homebrew (packages not in nixpkgs for darwin) ──
  homebrew = {
    enable = true;
    casks = ["ghostty"];
    onActivation.cleanup = "zap";
  };

  # ── Required by nix-darwin ──
  system.stateVersion = 6;
}
