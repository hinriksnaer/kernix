# Terminal -- all terminal tool configs.
{...}: {
  imports = [
    ./git.nix
    ./tmux
    ./herdr
    ./cli-tools.nix
    ./gh.nix
    ./zsh.nix
    ./direnv.nix
    ./neovim
    ./build-tools.nix
    ./btop.nix
    ./lazygit.nix
    ./yazi
    ./ibmcloud.nix
    ./bitwarden.nix
  ];
}
