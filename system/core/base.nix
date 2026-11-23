{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (config.kernix) username;
in {
  # ── Nix settings ──
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    max-jobs = "auto";
    # Numtide cache: prebuilt llm-agents.nix packages (codex, claude-code).
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };

  # Pin flake registry + nixPath to match this system's inputs.
  # Ensures `nix run nixpkgs#foo` uses the same nixpkgs as the system.
  nix.registry = lib.mapAttrs (_: flake: {inherit flake;}) inputs;
  nix.settings.nix-path = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;

  nixpkgs.config.allowUnfree = true;

  # ── Locale ──
  time.timeZone = config.kernix.timezone;
  i18n.defaultLocale = config.kernix.locale;

  # ── Users ──
  # Base groups only. Other modules add their own groups
  # (e.g. podman adds "docker", audio adds "audio").
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  # ── Foreign binaries ──
  # Prebuilt binaries that are not linked against NixOS's loader (PyPI wheels
  # with a binary in them, pre-commit hook environments, VSCode servers, some
  # language servers) fail with the stub-ld error until a real loader is
  # provided. The default library set covers the common case; do not append
  # GUI/CUDA libraries here, that is how a host turns into a second distro.
  programs.nix-ld.enable = true;

  # ── Core system packages ──
  environment.systemPackages = with pkgs; [
    curl
    wget
    which
    coreutils
    findutils
    gnused
    gnugrep
    gawk
    jq
    util-linux
    procps
    pkgs.kernix-cli.kernix
  ];

  system.stateVersion = "24.11";
}
