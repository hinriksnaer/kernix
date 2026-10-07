# Kernix shared library.
#
# lib/kernix-options.nix  -- Core cross-cutting NixOS options
# lib/monitor-type.nix    -- Shared monitor submodule type
# lib/gamescope.nix       -- Gamescope session defaults (parameterized)
#
# Theme data path: read the kernix.theme.dataDir option exposed by the
# kernix-theme Home Manager module.
{
  # Gamescope defaults -- call with: gsDefaults = import <kernix>/lib/gamescope.nix {inherit kernix lib;};
  gamescope = import ./gamescope.nix;
}
