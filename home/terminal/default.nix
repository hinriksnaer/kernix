# Terminal -- all terminal tool configs.
{...}: {
  imports = [
    ./git.nix
    ./tmux
    ./herdr
    ./cli-tools.nix
    ./claude-code.nix
    ./gh.nix
    ./zsh.nix
    ./direnv.nix
    ./neovim
    ./build-tools.nix
    ./opencode.nix
    ./vertex-auth.nix
    ./btop.nix
    ./lazygit.nix
    ./yazi
    ./ibmcloud.nix
    ./bitwarden.nix
  ];
}
