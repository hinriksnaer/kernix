# macOS (nix-darwin) host configuration.
# Apply with: darwin-rebuild switch --flake ~/kernix#macbook
{pkgs, ...}: {
  # ── Nix settings ──
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ── Homebrew (packages not in nixpkgs for darwin) ──
  homebrew = {
    enable = true;
    casks = ["ghostty"];
    onActivation.cleanup = "zap";
  };

  # ── Required by nix-darwin ──
  system.stateVersion = 6;
}
