# Shared helpers for the kernix theme engine.
{
  pkgs,
  config,
}: {
  kernixPath = "${config.home.homeDirectory}/.local/share/kernix";
}
