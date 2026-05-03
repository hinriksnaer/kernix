# ── User settings ──
# Single source of truth for all user-specific configuration.
# Type-checked against modules/core/kernix-options.nix.
# Imported by flake.nix and assigned to config.kernix.*.
{
  # ── Global (shared across all hosts) ──
  defaultTheme = "ayu-dark";

  git = {
    name = "hinriksnaer";
    email = "hgudmund@redhat.com";
  };

  opencode = {
    vertexProject = "itpc-gcp-ai-eng-claude";
    vertexRegion = "us-east5";
    cloudMlRegion = "global";
  };

  # ── Per-host settings ──
  hosts = {
    desktop = {
      username = "softmax";
      gpu = "nvidia";
      monitors = [
        {
          name = "HDMI-A-1";
          resolution = "7680x2160@120";
          scale = 1.5;
          primary = true;
        }
      ];
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
      cudaVisibleDevices = "4";

      projects = {
        helion = {
          enable = true;
          repo = "https://github.com/pytorch/helion.git";
          branch = "main";
          torchIndex = "nightly/cu130";
          backends = ["cute"];
        };
        pytorch = {
          enable = true;
          repo = "https://github.com/pytorch/pytorch.git";
          branch = "viable/strict";
          cudaArch = "9.0";
          buildTests = false;
          maxJobs = 32;
        };
        vllm = {
          enable = false;
          repo = "https://github.com/vllm-project/vllm.git";
          branch = "main";
          cudaArch = "9.0";
          maxJobs = 32;
          torchIndex = "nightly/cu130";
        };
      };
    };
  };
}
