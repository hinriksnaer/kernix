# Quadlet unit for the kernix dev container -- the single runtime
# declaration, identical on every host (workstation or bare ssh server,
# SELinux or not). Installed by `kernix container deploy` to
# ~/.config/containers/systemd/kernix-dev.container; systemd owns the
# lifecycle from then on (systemctl --user status kernix-dev).
#
# The named volumes kernix-nix (/nix) and kernix-home (/home/dev) seed
# from the image on first use and persist across redeploys, which is
# what makes init a once-per-host operation. No host path appears
# anywhere: nothing is bind-mounted from the host, so the unit deploys
# identically to any rootless-podman host (workstation, ssh server,
# cluster node).
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
  Volume=kernix-home:/home/dev
  # No-op without SELinux; on enforcing hosts (Fedora) lets the
  # container reach host sockets and home-labeled paths.
  SecurityLabelDisable=true

  [Service]
  Restart=always

  [Install]
  WantedBy=default.target
''
