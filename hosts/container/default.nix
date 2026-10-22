# Container profile -- consumed by any container with Nix; the repo ships no
# image or container tooling of its own. Runs as "dev" (uid 1000, home
# /home/dev), so the container must either run as that user or declare
# kernix.username = "root" here (rootless podman maps container-root to the
# host uid).
# Apply with:
#   nix run github:nix-community/home-manager -- \
#     switch --flake ~/kernix#dev@container
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
