# kernix dev container -- running it on a host

The host needs **podman** and (for auto-start) **systemd**. It does *not* need
nix: the container image carries its own, and the `root@container` profile is
applied from inside.

Everything stateful lives in the container's writable layer -- no volumes, no
bind mounts of `/nix`. A host contributes podman and a place for the container
to sit, nothing else.

## Run

```sh
podman run -d --name kernix --init --pull=newer \
  --security-opt label=disable \
  --device /dev/nvidiactl \
  --device /dev/nvidia-uvm \
  --device /dev/nvidia0 --device /dev/nvidia1 --device /dev/nvidia2 --device /dev/nvidia3 \
  --device /dev/nvidia4 --device /dev/nvidia5 --device /dev/nvidia6 --device /dev/nvidia7 \
  -v /lib64:/lib64:ro \
  -v /usr/lib64:/usr/lib64:ro \
  -v /usr/bin/nvidia-smi:/usr/bin/nvidia-smi:ro \
  -v /proc/driver/nvidia:/proc/driver/nvidia:ro \
  -e PATH=/root/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/usr/local/bin:/usr/bin:/bin \
  -e NIX_CONFIG='experimental-features = nix-command flakes' \
  docker.io/nixos/nix:latest sleep infinity
```

Adjust the `--device /dev/nvidiaN` list to the GPUs you want visible, and use
`/usr/lib/x86_64-linux-gnu` instead of `/usr/lib64` on Debian-family hosts.
Pin the image by digest rather than `:latest` if you want the run to be
reproducible.

### Why it looks like that

| Flag | Why |
|---|---|
| `-v /lib64` + `-v /usr/lib64` | Prebuilt FHS binaries -- the VS Code server's bundled node, `nvidia-smi`, pip wheels -- need a loader at `/lib64/ld-linux-x86-64.so.2` and a real glibc/libstdc++ on the standard paths. The image has neither. Nix binaries are unaffected: they resolve everything through RPATHs, so no `LD_LIBRARY_PATH` is needed (and setting one **breaks** them -- it makes them load a different glibc build and die with `GLIBC_PRIVATE` symbol errors). |
| host `/usr/lib64` also supplies `libcuda`/`libnvidia-*` | That replaces CDI (`--device nvidia.com/gpu=all`), which cannot be used here: it needs a writable `/usr/lib64` to inject into. `nixtorch` scans `/usr/lib64` for driver libs, so the GPU stack still finds them. |
| `-v /usr/bin/nvidia-smi` | CDI used to inject it; with the host loader mounted it now actually runs, which makes GPU debugging easy. |
| `-v /proc/driver/nvidia` | Lets `nvidia-smi` and the driver read `version`/`gpus/` from inside the container. |
| `-e PATH=...:/usr/bin:/bin` | The image's own PATH is nix-only. Without `/usr/bin` on it, the VS Code server's `check-requirements.sh` cannot even find `sed`. |
| `--security-opt label=disable` | On SELinux-enforcing hosts the GPU nodes are labelled `xserver_misc_device_t`, which the `container_t` domain cannot stat or open. The clean fix is an admin relabel to `nvidia_device_t` or a policy allowing container access; until then this is the user-side workaround. |
| `--init` | catatonit as PID 1: reaps zombies from builds and forwards SIGTERM so `podman stop` does not hang. |

## First run: two shims

The stock image is deliberately not FHS-compliant (`/usr/bin` holds only `env`,
`/usr/share` is a symlink into `/nix`). Two small shims are needed *before*
anything expects a normal distro:

```sh
# 1. /usr/bin entry points for coreutils/tar/etc. (PATH points there)
podman exec kernix sh -c '
for b in id cat ls mkdir rm chmod ln sed grep tar gzip which uname getent env bash sh; do
  p=$(command -v "$b" 2>/dev/null); [ -z "$p" ] && p=$(ls /nix/store/*/bin/"$b" 2>/dev/null | head -1)
  [ -n "$p" ] && ln -sf "$p" /usr/bin/"$b"
done'

# 2. os-release so the VS Code server skips its glibc probe
podman exec kernix sh -c 'printf "NAME=NixOS\nID=nixos\n" > /etc/os-release'
```

Shim 2 matters because `check-requirements.sh` looks for `/sbin/ldconfig` and
otherwise aborts with `Missing GLIBC >= 2.28` (exit 99). It has an explicit
early exit for `ID=nixos`, which is the documented way out; the host loader
mounts above then make the server actually run.

## Apply the profile

```sh
podman exec -it kernix nix run --refresh github:hinriksnaer/kernix#root@container
```

This is the whole configuration step: the flake is the interface, `--flake`
carries the host config, and Home Manager sanity-checks `$USER`/`$HOME` against
the profile (`root` / `/root` here).

Then, for the devShell and project venv:

```sh
podman exec -it kernix zsh -lc '
  rbw login && rbw unlock                       # git over ssh, agent-memory only
  git clone git@github.com:hinriksnaer/kernix.git /root/kernix
  cd ~/workspace && direnv allow                # builds the CUDA devShell
  nixtorch build'                               # torch wheels + helion in ~/workspace/.venv
```

The first `direnv allow` pulls several GB from `cache.nixos.org` and takes
~10 minutes.

## Verify

```sh
podman exec kernix sh -c 'id -u; sed --version | head -1'
podman exec kernix nvidia-smi -L                       # 8 GPUs
podman exec kernix zsh -lc 'cd ~/workspace && python -c "import torch; print(torch.cuda.is_available(), torch.cuda.device_count(), torch.cuda.get_device_capability(0))"'
# -> True 8 (10, 0)   on B200
```

## Snapshots

`podman rm` discards the store, the profile, the venv and the shims. To keep
them:

```sh
podman commit kernix kernix:snap        # ~43 GB and ~10 min for a CUDA profile
podman run ... localhost/kernix:snap    # same flags as above, --pull=never
```

Cheap insurance before any experiment that might recreate the container.

## VS Code / Dev Containers

Two independent requirements, easily confused:

* **Client side.** The Dev Containers extension probes the *local* user with
  `id -u -n` before it ever touches the container. On an sssd/LDAP machine a
  nix-built `id` cannot load `libnss_sss.so.2` and fails with
  `id: cannot find name for user ID <uid>`. Fixed in `hosts/fedora` (see
  `linkNssModules`), not in the container.
* **Server side.** The container needs the FHS loader/libs and the two shims
  above; that is what the run command and first-run steps provide.

`nvidia-smi` inside is a good smoke test for the server side -- if it runs, the
FHS layer is working.
