# Dev-container bootstrap image for hosts with nix (or a way to load an
# OCI archive).
#
# Built with the Nix project's own image builder (docker.nix from the
# pinned github:NixOS/nix input -- the builder behind the official
# nixos/nix images), but evaluated against kernix's locked nixpkgs, so
# nix, the bundled <nixpkgs> channel, and the baked store all come from
# flake.lock and stay coherent with the flake applied inside.
#
# The image carries only the bootstrap layer: nix (sandbox off, nixbld
# build users -- same posture as the official nix containers, no extra
# runtime capabilities needed on docker or podman), the locked
# home-manager CLI, and the bundled <nixpkgs> source. The actual
# environment is applied inside the container and lives in the
# container's writable layer:
#
#   nix run <flake>#root@container
#
# Build (any machine with nix):  nix build .#container-image
# Load:                          podman load < result
#
# Like the stock nixos/nix image, this is deliberately not FHS: the two
# first-run shims in README.md are still required.
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
      # Numtide cache: prebuilt llm-agents.nix packages (codex, claude-code).
      # Plain trusted-public-keys, not extra-: the generated nix.conf is
      # alphabetical, so upstream's own trusted-public-keys line would land
      # after an extra- line and reset it, dropping the numtide key.
      extra-substituters = "https://cache.numtide.com";
      trusted-public-keys = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
    };
  }
