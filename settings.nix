# ── User settings ──
# Single source of truth for all user-specific configuration.
# Type-checked against system/core/kernix-options.nix.
# Imported by flake.nix and assigned to config.kernix.*.
{
  # ── Global (shared across all hosts) ──
  terminal = "ghostty"; # ghostty | kitty
  defaultTheme = "ayu-dark";

  font = {
    monospace = "Maple Mono NF";
  };

  git = {
    name = "hinriksnaer";
    email = "hgudmund@redhat.com";
  };

  opencode = {
    vertexProject = "itpc-gcp-ai-eng-claude";
    cloudMlRegion = "global";
  };

  # ── Per-host settings ──
  hosts = {
    desktop = {
      username = "softmax";
      gpu = "nvidia";
      layout = "master";
      monitors = [
        {
          name = "HDMI-A-1";
          resolution = "7680x2160@120";
          scale = 1.0;
          primary = true;
        }
      ];

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

    laptop = {
      username = "hgudmund";
      gpu = "intel";
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

    remote = {
      username = "hgudmund";

      # Passed directly to nixtorch.lib.mkDevShell
      nixtorch = {
        cudaVisibleDevices = "";
        workspace = "$HOME/workspace";
        projects = {
          pytorch = {
            cudaArch = "9.0";
            maxJobs = 16;
          };
          helion = {
            torchIndex = "nightly/cu130";
            backends = ["cute"];
          };
        };
      };
    };

    macbook = {
      username = "dev";
      homePrefix = "/Users";
    };

    container = {
      username = "root";
      kernixRoot = "$HOME/workspace/settings";

      nixtorch = {
        cudaVisibleDevices = "";
        cudaVersion = "13";
        workspace = "$HOME/workspace";
        projects = {
          pytorch = {
            cudaArch = "9.0";
            maxJobs = 16;
          };
          helion = {
            torchIndex = "nightly/cu130";
            backends = ["cute"];
          };
        };
      };
    };
  };
}
