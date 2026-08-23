# Laptop host -- Intel GPU, power management, no gaming.
{...}: {
  imports = [
    ./hardware-configuration.nix
    ./power.nix
  ];

  kernix = {
    username = "hgudmund";
    gpu = "intel";

    git = {
      name = "hinriksnaer";
      email = "hgudmund@redhat.com";
    };

    opencode = {
      vertexProject = "itpc-gcp-ai-eng-claude";
    };

    # Laptop-specific hardware
    hardware.wifi.powersave = true;
    hardware.bluetooth.powerOnBoot = false;

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

    apps.enable = true;
  };
}
