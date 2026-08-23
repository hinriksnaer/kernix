# Core system -- always active on NixOS hosts.
# Imports lib/kernix-options.nix for the base option schema.
# Feature modules (desktop, gaming, etc.) declare their own options.
{...}: {
  imports = [
    ../../lib/kernix-options.nix
    ../assertions.nix
    ./base.nix
    ./zsh.nix
    ./nh.nix
  ];
}
