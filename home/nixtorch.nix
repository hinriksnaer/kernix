# Auto-activate nixtorch devshell via direnv for hosts that define nixtorch config.
{
  lib,
  pkgs,
  config,
  host,
  hostname,
  ...
}: let
  hasNixtorch = host.nixtorch != {};
  homeDir = config.home.homeDirectory;
  kernixRoot =
    if host.kernixRoot != ""
    then host.kernixRoot
    else "${homeDir}/kernix";
  workspaceDir = host.nixtorch.workspace or "${homeDir}/workspace";
in {
  config = lib.mkIf hasNixtorch {
    home.activation.setupDirenv = config.lib.dag.entryAfter ["linkGeneration"] ''
      mkdir -p "${workspaceDir}"
      envrc="${workspaceDir}/.envrc"
      if [ ! -f "$envrc" ] || ! grep -q "use flake ${kernixRoot}#${hostname}" "$envrc" 2>/dev/null; then
        echo "use flake ${kernixRoot}#${hostname}" > "$envrc"
      fi
      ${pkgs.direnv}/bin/direnv allow "$envrc" 2>/dev/null || true
    '';
  };
}
