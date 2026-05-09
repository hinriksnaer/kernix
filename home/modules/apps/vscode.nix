# Visual Studio Code with base extensions.
# Extensions dir is mutable -- install additional extensions from the marketplace.
# Settings are managed by VS Code directly (not locked by Nix).
{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # AI
        saoudrizwan.claude-dev

        # Python
        ms-python.python
        ms-python.vscode-pylance

        # Vim
        vscodevim.vim

        # Theme
        teabyii.ayu
        pkief.material-icon-theme

        # Remote
        ms-vscode-remote.remote-ssh
      ];
    };
  };
}
