# Yazi -- terminal file manager with preview support.
# Fully managed by Home Manager's programs.yazi module.
# theme.toml is NOT managed here -- kernix-theme-set writes it at runtime.
{pkgs, ...}: {
  kernix.theme.hooks = ["yazi"];

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    # Plugins from nixpkgs (pkgs.yaziPlugins)
    plugins = {
      inherit (pkgs.yaziPlugins) smart-enter smart-filter;
    };

    settings = import ./settings.nix;
    keymap = import ./keymap.nix;

    initLua = ''
      -- Minimal custom linemode showing only size
      function Linemode:size_only()
        local size = self._file:size()
        return ui.Line(size and ya.readable_size(size) or "-")
      end
    '';
  };

  # Preview support packages
  home.packages = with pkgs; [
    file # MIME detection
    ffmpegthumbnailer # video thumbnails
    poppler-utils # PDF preview
    imagemagick # image preview
  ];

  # Kernix theme-map.conf (not standard yazi config, used by kernix-theme-set)
  xdg.configFile."yazi/theme-map.conf".source = ../../theme/theme-map.conf;
}
