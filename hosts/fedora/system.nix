# System-level config for Fedora CSB -- managed by system-manager.
# Handles what NixOS system modules provide on NixOS hosts but HM cannot:
# fonts and fontconfig.
#
# Apply with: nix run github:numtide/system-manager -- switch --flake <path>#fedora --sudo
{pkgs, ...}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  system-manager.allowAnyDistro = true;

  # ── Fonts (replicates system/desktop/fonts.nix) ──
  environment.systemPackages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    maple-mono.NF
    nerd-fonts.symbols-only
  ];

  # ── Fontconfig ──
  environment.etc."fonts/local.conf" = {
    text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <match target="font">
          <edit name="antialias" mode="assign"><bool>true</bool></edit>
        </match>
        <match target="font">
          <edit name="hinting" mode="assign"><bool>true</bool></edit>
        </match>
        <match target="font">
          <edit name="hintstyle" mode="assign"><const>hintfull</const></edit>
        </match>
        <match target="font">
          <edit name="rgba" mode="assign"><const>rgb</const></edit>
        </match>
        <match target="font">
          <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
        </match>
      </fontconfig>
    '';
  };
}
