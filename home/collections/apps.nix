# Apps collection -- GUI applications and tools.
# Import this in desktop/laptop profiles alongside terminal.nix and desktop.nix.
{ ... }:

{
  imports = [
    ../modules/apps/apps.nix
    ../modules/apps/vscode.nix
  ];
}
