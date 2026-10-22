# VS Code -- GUI counterpart to the terminal editor stack.
# Settings and extensions are managed by VS Code itself, not by Nix.
#
# FHS vs plain build is host-dependent; see kernix.apps.vscodeFhs for why.
{
  pkgs,
  host,
  lib,
  ...
}:
lib.mkIf host.apps.enable {
  home.packages = [
    (if host.apps.vscodeFhs
     then pkgs.vscode-fhsWithPackages (ps: [ps.openssh])
     else pkgs.vscode)
  ];
}
