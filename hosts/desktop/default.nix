# Desktop host -- primary workstation with NVIDIA GPU, gaming, and couch mode.
{...}: {
  imports = [
    ./hardware-configuration.nix
    ./fancontrol.nix
  ];

  kernix = {
    username = "softmax";
    gpu = "nvidia";

    git = {
      name = "hinriksnaer";
      email = "hgudmund@redhat.com";
    };

    desktop = {
      enable = true;
      monitors = [
        {
          name = "DP-2";
          resolution = "7680x2160@120";
          scale = 1.0;
          primary = true;
        }
      ];
      hyprland = {
        layout = "master";
        tvOutput = "HDMI-A-1";
        hdr = true;
      };
    };

    gaming = {
      enable = true;
      gamescope = {
        resolution = "3840x2160";
        refreshRate = 60;
      };
    };

    apps.enable = true;

    nixtorch = {
      cudaVisibleDevices = "";
      workspace = "$HOME/workspace";
      projects = {
        pytorch = {
          cudaArch = "8.6";
          maxJobs = 8;
        };
        helion = {
          torchIndex = "nightly/cu130";
          backends = ["cute"];
        };
      };
    };
  };
}
