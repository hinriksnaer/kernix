# Mako notification daemon.
# Theme colors loaded at runtime via include (swapped by kernix-theme-set).
{...}: {
  kernix.theme.hooks = ["mako"];

  services.mako = {
    enable = true;

    settings = {
      width = 420;
      height = 110;
      padding = 10;
      border-size = 2;
      border-radius = 8;
      font = "Maple Mono NF SemiBold 11";

      anchor = "top-right";
      outer-margin = 20;

      default-timeout = 5000;
      ignore-timeout = 0;
      max-visible = 5;
      sort = "-time";

      max-icon-size = 48;
      group-by = "app-name";

      # Theme colors (symlinked by kernix-theme-apply)
      include = "~/.config/mako/theme.conf";
    };
  };
}
