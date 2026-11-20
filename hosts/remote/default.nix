# Remote server profile -- non-NixOS host with Nix installed.
# Apply with: home-manager switch --flake ~/kernix#hgudmund@remote
{...}: {
  kernix = {
    username = "hgudmund";

    git = {
      name = "hinriksnaer";
      email = "hgudmund@redhat.com";
    };
  };
}
