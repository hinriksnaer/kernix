# Macbook profile -- Apple Silicon Mac managed by nix-darwin.
# Applied via darwinConfigurations (darwin-rebuild switch --flake ~/kernix#macbook).
{
  config,
  settings,
  hostname,
  ...
}: let
  username = settings.hosts.${hostname}.username;
  homeDir = "/Users/${username}";
  kernixRoot = "${homeDir}/kernix";
in {
  imports = [
    # Terminal collection minus ibmcloud
    ../modules/terminal/git.nix
    ../modules/terminal/tmux
    ../modules/terminal/cli-tools.nix
    ../modules/terminal/gh.nix
    ../modules/terminal/zsh.nix
    ../modules/terminal/direnv.nix
    ../modules/terminal/neovim
    ../modules/terminal/build-tools.nix
    ../modules/theme
    ../modules/terminal/opencode.nix
    ../modules/terminal/btop.nix
    ../modules/terminal/lazygit.nix
    ../modules/terminal/yazi.nix
  ];

  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "24.11";

  home.sessionVariables.KERNIX_ROOT = kernixRoot;

  # Ghostty -- installed via Homebrew cask, configured via Home Manager.
  # package = null avoids installing via Nix (the .app comes from Homebrew).
  programs.ghostty = {
    enable = true;
    package = null;
    enableZshIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;
      font-style = "SemiBold";
      font-thicken = true;
      window-padding-x = 14;
      window-padding-y = 14;
      confirm-close-surface = false;
      cursor-style = "block";
      mouse-hide-while-typing = true;
      config-file = "theme";
      macos-option-as-alt = true;
      keybind = [
        "super+c=copy_to_clipboard"
        "super+v=paste_from_clipboard"
      ];
    };
  };

  # Ghostty theme hook (auto-reload: Ghostty watches config files on macOS)
  xdg.configFile."kernix/theme-hooks.d/14-ghostty".text = ''
    source=ghostty.conf
    target=~/.config/ghostty/theme
  '';

  # Seed empty theme file so Ghostty doesn't error on first launch
  home.activation.ghosttyThemeStub = config.lib.dag.entryAfter ["linkGeneration"] ''
    [ -e "$HOME/.config/ghostty/theme" ] || touch "$HOME/.config/ghostty/theme"
  '';
}
