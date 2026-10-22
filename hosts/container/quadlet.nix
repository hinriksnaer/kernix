# Quadlet unit for the kernix dev container -- the single runtime
# declaration, identical on every host (workstation or bare ssh server,
# SELinux or not). Installed by `kernix container deploy` to
# ~/.config/containers/systemd/kernix-dev.container; systemd owns the
# lifecycle from then on (systemctl --user status kernix-dev).
#
# The named volumes kernix-nix (/nix) and kernix-home (/root) seed from
# the image on first use and persist across redeploys, which is what
# makes init a once-per-host operation.
{
  # Image reference. Defaults to the tag produced by
  # `podman load`-ing the flake's container-image tarball. Point this at
  # a registry (e.g. ghcr.io/...) to switch distribution from ssh-pipe
  # to pull -- still one declaration for every host.
  image ? "localhost/kernix:container",
}: ''
  [Container]
  Image=${image}
  ContainerName=kernix-dev
  Exec=sleep infinity
  Volume=kernix-nix:/nix
  Volume=kernix-home:/root
  # No-op without SELinux; on enforcing hosts (Fedora) lets the
  # container reach host sockets and home-labeled paths.
  SecurityLabelDisable=true

  [Service]
  Restart=always

  [Install]
  WantedBy=default.target
''
