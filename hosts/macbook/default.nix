# macOS (nix-darwin) host configuration.
# Apply with: sudo darwin-rebuild switch --flake ~/kernix#macbook
{config, ...}: {
  kernix = {
    username = "dev";
    homePrefix = "/Users";

    git = {
      name = "hinriksnaer";
      email = "hgudmund@redhat.com";
    };

    opencode = {
      vertexProject = "itpc-ca-f56dba0f61";
    };
  };

  # ── Nix settings ──
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ── Primary user (required by nix-darwin for root activation) ──
  system.primaryUser = config.kernix.username;

  # ── User (home directory must be declared for home-manager integration) ──
  users.users.${config.kernix.username}.home = "${config.kernix.homePrefix}/${config.kernix.username}";

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
      "font-maple-mono-nf"
    ];
    onActivation.cleanup = "zap";
  };

  # ── Required by nix-darwin ──
  system.stateVersion = 6;
}
