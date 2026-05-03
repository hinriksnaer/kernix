{ config, pkgs, lib, inputs, ... }:

let
  inherit (config.kernix) username;
in
{
  # ── Nix settings ──
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = "auto";
  };

  # Pin flake registry + nixPath to match this system's inputs.
  # Ensures `nix run nixpkgs#foo` uses the same nixpkgs as the system.
  nix.registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
  nix.nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") inputs;

  nixpkgs.config.allowUnfree = true;

  # ── Locale ──
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ── Users ──
  # Base groups only. Other modules add their own groups
  # (e.g. podman adds "docker", audio adds "audio").
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  # ── Core system packages ──
  environment.systemPackages = with pkgs; [
    curl wget which coreutils findutils gnused gnugrep gawk
    util-linux procps
    pkgs.kernix-cli.kernix
  ];

  system.stateVersion = "24.11";
}
