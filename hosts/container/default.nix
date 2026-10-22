# Container profile -- the flake-built dev container (nix build
# .#container-image), which runs as the unprivileged user "dev" (uid
# 1000, home /home/dev) so nothing inside runs as root.
# Apply with: home-manager switch --flake ~/kernix#dev@container
{...}: {
  kernix = {
    username = "dev";
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
