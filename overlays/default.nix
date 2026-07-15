# Overlays -- custom packages and modifications to nixpkgs.
# Applied globally in flake.nix so all modules can access them.
# Each package-level fix lives in its own file for easy addition/removal.
{inputs}: {
  # Custom packages added to pkgs namespace
  additions = final: _prev: {
    kernix-cli = import ../cli {pkgs = final;};
  };

  # Make flake input packages available as pkgs.inputs'.<name>
  # Usage: pkgs.inputs'.home-manager.default, etc.
  flake-inputs = final: _: {
    inputs' =
      builtins.mapAttrs
      (
        _: flake: let
          packages = (flake.packages or {}).${final.stdenv.hostPlatform.system} or {};
        in
          packages
      )
      inputs;
  };

  # Patches/overrides to upstream nixpkgs packages
  electron = import ./electron.nix;
}
