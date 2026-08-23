# Container profile -- Kubernetes/OpenShift pods running as root.
# Apply with: nix run home-manager/master -- switch --flake ~/workspace/settings#root@container
{...}: {
  kernix = {
    username = "root";
    kernixRoot = "$HOME/workspace/settings";

    git = {
      name = "hinriksnaer";
      email = "hgudmund@redhat.com";
    };

    opencode = {
      vertexProject = "itpc-gcp-ai-eng-claude";
    };

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
}
