# Overlays -- custom packages and modifications to nixpkgs.
# Applied globally in flake.nix so all modules can access them.
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
          packages = (flake.packages or {}).${final.system} or {};
        in
          packages
      )
      inputs;
  };

  # Patches/overrides to upstream nixpkgs packages
  modifications = _final: _prev: {
    # Example: patch a package
    # foo = prev.foo.overrideAttrs (old: { ... });
  };
}
