# Fedora CSB -- non-NixOS desktop host.
# Provides: genericLinux integration, GPU driver setup, Hyprland + Wayland
# session via Nix (unavailable in Fedora repos without third-party COPR),
# XDG portals, and CLI helper.
{
  pkgs,
  lib,
  host,
  hostname,
  ...
}: let
  username = host.username;
  cli = import ../../cli {
    inherit pkgs;
    hostType = "hm";
    hmProfile = "${username}@${hostname}";
  };
in {
  # ── Non-NixOS Linux integration ──
  targets.genericLinux.enable = true;

  # GPU: build Mesa driver env from nixpkgs, symlink to /run/opengl-driver.
  # First-time setup requires: sudo non-nixos-gpu-setup
  targets.genericLinux.gpu.enable = true;

  # ── Shell ──
  # SSSD-managed accounts cannot use chsh; tell Ghostty to launch zsh
  # directly and keep the bash exec as a fallback for other terminals.
  programs.ghostty.settings.command = "${pkgs.zsh}/bin/zsh";
  programs.bash.initExtra = ''
    if [[ -x "${pkgs.zsh}/bin/zsh" && -z "$_ZSH_EXEC_GUARD" ]]; then
      export _ZSH_EXEC_GUARD=1
      export SHELL="${pkgs.zsh}/bin/zsh"
      exec "${pkgs.zsh}/bin/zsh" -l
    fi
  '';

  # ── SSSD / LDAP name resolution for Nix binaries ──
  # Nix glibc reads the host's /etc/nsswitch.conf (`files sss ...`) but does
  # not search /usr/lib64 for libnss_sss.so.2, so every Nix-built getpwuid()
  # fails on this domain machine:
  #   $ id -u -n        ->  id: cannot find name for user ID 4240723
  # This is the same root cause as the nix-openssh Remote-SSH breakage above
  # (hence vscodeFhs = false), and it also breaks VS Code's dev-containers
  # extension, which probes the container with `id -u -n`.
  # Collect the host's NSS modules in a private dir so it can be put on
  # LD_LIBRARY_PATH without exposing the rest of /usr/lib64.
  home.activation.linkNssModules = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "$HOME/.local/lib/nss"
    for _m in libnss_sss.so.2 libnss_systemd.so.2 libnss_mdns4_minimal.so.2; do
      for _d in /usr/lib64 /usr/lib/x86_64-linux-gnu; do
        if [ -e "$_d/$_m" ]; then
          run ln -sf "$_d/$_m" "$HOME/.local/lib/nss/$_m"
        fi
      done
    done
    unset _m _d
  '';

  # ── Hyprland + Wayland session ──
  home.packages = with pkgs; [
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xwayland
    cli.kernix
  ];
}
