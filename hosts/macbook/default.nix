# macbook -- nix-darwin system configuration for Apple Silicon Mac.
# Apply with: sudo darwin-rebuild switch --flake ~/kernix#macbook
{pkgs, ...}: {
  # ── Primary user (required: nix-darwin runs activation as root) ──
  system.primaryUser = "softmax";

  # ── Nix daemon ──
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    warn-dirty = false;
  };

  # ── Homebrew (managed by nix-darwin) ──
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "ghostty"
    ];
  };

  # ── Fonts ──
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # ── System defaults ──
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      FHideExtensionChangeWarning = true;
    };
  };

  # ── Touch ID for sudo ──
  security.pam.services.sudo_local.touchIdAuth = true;

  # ── Shell ──
  programs.zsh.enable = true;

  # Required by nix-darwin
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
