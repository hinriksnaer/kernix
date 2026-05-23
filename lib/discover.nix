# Auto-discovery helpers for NixOS modules.
# Scans directories and imports .nix files / subdirectories with default.nix.
{lib}: let
  # Import every .nix file in a directory as a named module.
  discoverModules = dir:
    lib.mapAttrs'
    (
      name: _:
        lib.nameValuePair
        (lib.removeSuffix ".nix" name)
        (import (dir + "/${name}"))
    )
    (
      lib.filterAttrs
      (name: type: type == "regular" && lib.hasSuffix ".nix" name)
      (builtins.readDir dir)
    );

  # Import every subdirectory that contains a default.nix.
  discoverDirs = dir:
    lib.mapAttrs'
    (name: _: lib.nameValuePair name (import (dir + "/${name}")))
    (
      lib.filterAttrs
      (name: type: type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
      (builtins.readDir dir)
    );

  # Discover both files and directories.
  discoverAll = dir: (discoverModules dir) // (discoverDirs dir);
in {
  inherit discoverModules discoverDirs discoverAll;
}
