# Container profile -- root inside OCI containers: Kubernetes/OpenShift
# pods, or the flake-built image (nix build .#container-image).
# Apply with: home-manager switch --flake ~/kernix#root@container
{...}: {
  kernix = {
    username = "root";
    kernixRoot = "$HOME/kernix";

    git = {
      name = "hinriksnaer";
      email = "hgudmund@redhat.com";
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
