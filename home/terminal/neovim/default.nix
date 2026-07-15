# Neovim -- package, LSP/tooling deps, and config.
# Lua config lives in ./neovim/ alongside this module and is symlinked
# into ~/.config/nvim/ at build time via the Nix store.
{pkgs, ...}: {
  kernix.theme.hooks = ["neovim"];

  home.packages = with pkgs; [
    neovim
    tree-sitter
    nodejs # required by Copilot
    clang-tools # clangd + clang-format
    pyrefly # Python LSP
    python3Packages.debugpy # Python DAP adapter
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
