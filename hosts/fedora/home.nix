# Fedora CSB -- non-NixOS desktop host.
# Provides: genericLinux integration, GPU driver setup, Hyprland + Wayland
# session via Nix (unavailable in Fedora repos without third-party COPR),
# XDG portals, and CLI helper.
{
  pkgs,
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
      exec "${pkgs.zsh}/bin/zsh" -l
    fi
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
