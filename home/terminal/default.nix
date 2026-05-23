# Terminal -- all terminal tool configs.
{...}: {
  imports = [
    ./git.nix
    ./tmux
    ./cli-tools.nix
    ./claude-code.nix
    ./gh.nix
    ./zsh.nix
    ./direnv.nix
    ./neovim
    ./build-tools.nix
    ../theme
    ./opencode.nix
    ./vertex-auth.nix
    ./btop.nix
    ./lazygit.nix
    ./yazi.nix
    ./ibmcloud.nix
  ];
}
