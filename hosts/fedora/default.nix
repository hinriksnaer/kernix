# Fedora CSB host -- Hyprland desktop via Nix on Fedora.
# Apply with: kernix rebuild (or see bootstrap.sh for first-time setup)
{...}: {
  kernix = {
    username = "hgudmund";

    git = {
      name = "hinriksnaer";
      email = "hgudmund@redhat.com";
    };

    apps.enable = true;

    desktop = {
      enable = true;
      monitors = [
        {
          name = "";
          resolution = "preferred";
          position = "auto";
          scale = 1.0;
          primary = true;
        }
      ];
    };
  };
}
