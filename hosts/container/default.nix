# Container profile -- consumed by any container with Nix; the repo ships no
# image or container tooling of its own.
#
# Runs as "root": the stock nixos/nix image runs as root, and under rootless
# podman container-root is the host uid, not host root. Home Manager sanity
# checks $USER/$HOME against the profile, so this must match whoever the
# container runs as -- switch back to a uid-1000 user here if this ever runs
# rootful or on a shared host.
#
# Apply from inside the container with one command:
#   nix run <flake>#root@container
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
