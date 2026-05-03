# Terminal collection -- all terminal tool configs.
# Import this in a profile to get the full terminal setup.
{ ... }:

{
  imports = [
    ../modules/terminal/git.nix
    ../modules/terminal/tmux.nix
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
}
