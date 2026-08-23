{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf config.kernix.desktop.enable {
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      font-awesome
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      google-fonts
      maple-mono.NF
      nerd-fonts.symbols-only
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      defaultFonts = {
        monospace = [config.kernix.font.monospace];
        sansSerif = ["Noto Sans"];
        serif = ["Noto Serif"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };
}
