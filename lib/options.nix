# Standalone kernix option schema -- for non-NixOS evaluation contexts.
# Used by evalHost (standalone HM) and Darwin, which don't import the
# full system module tree. NixOS hosts get options through each module's
# default.nix instead.
{...}: {
  imports = [
    ./kernix-options.nix
    ../system/desktop/options.nix
    ../system/desktop/hyprland/options.nix
    ../system/gaming/options.nix
    ../system/gaming/steam/options.nix
    ../system/gaming/sunshine/options.nix
    ../system/gaming/couch/options.nix
    ../system/apps/options.nix
    ../system/apps/podman/options.nix
    ../system/hardware/options.nix
    ../system/hardware/bluetooth/options.nix
    ../system/hardware/networking/options.nix
  ];
}
