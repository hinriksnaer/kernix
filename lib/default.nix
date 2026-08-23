# Kernix shared library.
#
# lib/kernix-options.nix  -- Core cross-cutting NixOS options
# lib/monitor-type.nix    -- Shared monitor submodule type
# lib/gamescope.nix       -- Gamescope session defaults (parameterized)
# lib/theme.nix           -- Theme engine helpers (import with {pkgs, config})
{
  # Theme helpers -- call with: themeLib = import <kernix>/lib/theme.nix {inherit pkgs config;};
  theme = import ./theme.nix;

  # Gamescope defaults -- call with: gsDefaults = import <kernix>/lib/gamescope.nix {inherit kernix lib;};
  gamescope = import ./gamescope.nix;
}
