# Kernix shared library.
#
# lib/kernix-options.nix  -- Core cross-cutting NixOS options
# lib/monitor-type.nix    -- Shared monitor submodule type
# lib/gamescope.nix       -- Gamescope session defaults (parameterized)
#
# Theme engine helpers moved to the kernix-theme flake
# (inputs.kernix-theme.lib.theme).
{
  # Gamescope defaults -- call with: gsDefaults = import <kernix>/lib/gamescope.nix {inherit kernix lib;};
  gamescope = import ./gamescope.nix;
}
