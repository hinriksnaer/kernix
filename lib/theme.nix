# Shared helpers for the kernix theme engine.
{
  pkgs,
  config,
}: let
  kernixPath = "${config.home.homeDirectory}/.local/share/kernix";
  scripts = ../home/theme/scripts;
in {
  inherit kernixPath scripts;

  mkScript = name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = ''
        export KERNIX_PATH="${kernixPath}"
        ${builtins.readFile "${scripts}/${name}.sh"}
      '';
    };
}
