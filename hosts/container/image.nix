# Dev-container bootstrap image for non-Nix hosts.
#
# Built with the Nix project's own image builder (docker.nix from the
# pinned github:NixOS/nix input -- the builder behind the official
# nixos/nix images), but evaluated against kernix's locked nixpkgs, so
# nix, the bundled <nixpkgs> channel, and the baked store all come from
# flake.lock and stay coherent with the flake applied inside.
#
# The image carries only the bootstrap layer: nix (sandbox off, nixbld
# build users -- same posture as the official nix containers, no extra
# runtime capabilities needed on docker or podman), git, openssh, the
# locked home-manager CLI, and the bundled <nixpkgs> source. The actual
# environment is applied inside the container and lives on the /nix
# volume:
#
#   git clone --recurse-submodules <kernix> ~/kernix
#   home-manager switch --flake ~/kernix#dev@container -b backup
#   kernix rebuild   # thereafter
#
# Build (on a machine with nix):  nix build .#container-image
# Load:                           podman load < result
{
  pkgs,
  inputs,
}: let
  # Home Manager CLI pinned to the flake lock: the first `switch` inside
  # a fresh container uses the same HM version the profile is built with.
  home-manager = inputs.home-manager.packages.${pkgs.system}.home-manager;
in
  import "${inputs.nix}/docker.nix" {
    inherit pkgs;
    name = "kernix";
    tag = "container";
    # Unprivileged runtime user: the container runs as uid 1000 "dev"
    # with the whole store chowned to it (single-user nix, no daemon),
    # keeping interactive and agent workflows off container-root.
    uid = 1000;
    gid = 1000;
    uname = "dev";
    gname = "dev";
    extraPkgs = [home-manager];
    # Bundle the locked nixpkgs as <nixpkgs>: nix-shell -p and
    # nix-build '<nixpkgs>' work offline, pinned to flake.lock like a
    # NixOS host is pinned to its system channel.
    bundleNixpkgs = true;
    maxLayers = 70;
    Labels = {
      "org.opencontainers.image.source" = "https://github.com/hinriksnaer/kernix";
      "org.opencontainers.image.description" = "kernix dev container";
    };
    # nixConf: upstream defaults (sandbox = false, nixbld build users,
    # cache.nixos.org key) plus flakes, which the official images leave
    # off. Re-enable build isolation with sandbox = true; if the runtime
    # allows user namespaces (rootless podman does, stock docker does not).
    nixConf = {
      experimental-features = "nix-command flakes";
    };
  }
