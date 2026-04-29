# Visual Studio Code with extensions and theme.
# Extensions are managed declaratively -- install/update via hawker-switch.
{ pkgs, lib, ... }:

let
  # Extensions shared between local and remote SSH sessions.
  sharedExtensions = with pkgs.vscode-extensions; [
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
  ];

  # Derive "publisher.name" identifiers for remote.SSH.defaultExtensions.
  sharedExtensionIds = map (ext: "${ext.vscodeExtPublisher}.${ext.vscodeExtName}") sharedExtensions;
in
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = sharedExtensions ++ (with pkgs.vscode-extensions; [
        # Remote
        ms-vscode-remote.remote-ssh
      ]);

      userSettings = {
        "workbench.colorTheme" = "Ayu Dark";
        "workbench.iconTheme" = "material-icon-theme";

        # Sync settings and extensions to remote SSH sessions
        "remote.SSH.useLocalServer" = true;
        "remote.SSH.defaultExtensions" = sharedExtensionIds;
      };
    };
  };
}
