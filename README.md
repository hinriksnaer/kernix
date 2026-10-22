# kernix

One Nix flake for every machine. Desktop, laptop, server, container -- same repo, same modules, one rebuild.

## Why

Maintaining separate configs per machine drifts fast. Kernix keeps everything in a single flake so every host is composed from the same module library. Type-checked options catch misconfigurations at eval time, not after a broken boot.

## Hosts

| Host | Platform | Layer | Notes |
|---|---|---|---|
| `desktop` | NixOS x86_64 | NixOS + Home Manager | NVIDIA, multi-monitor workstation |
| `laptop` | NixOS x86_64 | NixOS + Home Manager | Intel GPU, power management |
| `remote` | Linux | Home Manager only | Headless server |
| `container` | Linux | Home Manager only | OCI pods + flake-built image, CUDA dev |
| `fedora` | Fedora Linux | Home Manager only | Hyprland via Nix on Fedora |

Full hosts get OS-level config (boot, GPU drivers, networking). Headless hosts get user-level tooling only, portable to any Linux with Nix.

## Key Features

**Layered composition** -- `system/` handles OS-level modules (hardware, boot, GPU drivers, services), `home/` handles user-level modules (terminal, desktop, apps, themes). Each host picks what it needs. Adding a machine is a thin config file.

**Type-checked settings** -- All per-host options (GPU, monitors, git identity, CUDA config) are validated by typed NixOS modules. Bad config fails at eval, not at runtime.

**Runtime theme switching** -- 11+ themes that propagate across Hyprland, Ghostty, Neovim, btop, Waybar, mako, rofi, and hyprlock with no rebuild. `Super+T` to pick, `Super+Shift+T` to cycle.

**CUDA dev shells** -- Powered by [nixtorch](https://github.com/hinriksnaer/nixtorch). Build PyTorch and Helion from source with configurable CUDA architectures. Direnv auto-activates the shell.

**Gaming** -- Steam with Proton, Gamescope sessions, Sunshine remote play, couch mode with TV output.

**Terminal stack** -- Zsh with vi-mode, tmux with sesh session management, Neovim with tree-sitter/LSP/Copilot, lazygit, yazi, fzf, zoxide, starship, and more.

**Editors** -- Visual Studio Code as the GUI counterpart to the terminal stack, built with the FHS variant so marketplace extensions work out of the box. Settings and extensions are managed by VS Code itself, not by Nix.

## Quick Start

```sh
git clone git@github.com:hinriksnaer/kernix.git ~/kernix
# Edit hosts/<hostname>/ -- set username, git identity, GPU, monitors
kernix rebuild
```

### In a container

This repo ships no container tooling -- the flake is the interface, and every
profile is runnable as an app:

```sh
nix run <flake>#<user>@<host>          # e.g. nix run .#root@container
```

That is equivalent to `home-manager switch --flake <flake>#<user>@<host>`
(Home Manager is referenced by the app, so there is no second flake URL). It
must run as the profile's user: Home Manager sanity-checks `$USER`, `$HOME`
and uid against the configuration.

Bootstrapping the stock image (runs as root, so the profile is
`root@container`, home `/root`):

```sh
podman run -d --restart=always --name kernix \
  -e NIX_CONFIG='experimental-features = nix-command flakes' \
  docker.io/nixos/nix:2.35.3

# copy the working tree in -- no mounts, ~1MB -- then apply it
tar -c --exclude=.git --exclude=result -C ~ kernix \
  | ssh <user>@<remote> 'podman exec -i kernix tar -x -C /root'
podman exec -it -w /root kernix sh -l
nix run /root/kernix#root@container
```

Once the flake is pushed, the copy is unnecessary:
`nix run github:hinriksnaer/kernix#root@container`.

No volume over `/nix`: state lives in the container's writable layer and
survives stop/start/reboot. Consuming the working tree means uncommitted
edits apply.

The root profile is a deliberate choice: under rootless podman
container-root is the host uid, not host root. For a rootful or shared host,
set `kernix.username` in `hosts/container/default.nix` to a uid-1000 user
instead and run the container as that user.

### GPU passthrough (NVIDIA)

Two things have to cross the boundary: the device nodes and the *driver*
libraries. On a host with `nvidia-container-toolkit` installed, CDI supplies
both from one flag:

```sh
podman run -d --name kernix --init --pull=newer \
  --device nvidia.com/gpu=all \
  --tmpfs /usr/share --tmpfs /usr/lib64 \
  --security-opt label=disable \
  -e NIX_CONFIG='experimental-features = nix-command flakes' \
  docker.io/nixos/nix:latest sleep infinity
```

Three parts of that are not obvious:

- `nixos/nix` has no `/usr/lib64`, and its `/usr/share` is a symlink into
  `/nix`. CDI writes real files into both, so without the `--tmpfs` mounts
  container creation fails with
  `openat2 usr/share: No such file or directory`.
- On SELinux-enforcing hosts the GPU nodes may be labelled
  `xserver_misc_device_t`, which the `container_t` domain cannot access --
  `stat /dev/nvidia0` returns EACCES even though the host user can open it.
  `--security-opt label=disable` is the user-side workaround; the clean fix is
  an admin relabel to `nvidia_device_t`, or a policy allowing container access.
- `nvidia-smi` cannot run in this image at all, because it needs
  `/lib64/ld-linux-x86-64.so.2`, which the image does not provide. CDI still
  injects the binary, so its presence proves nothing. Check the driver API
  instead:
  `python -c 'import ctypes; print(ctypes.CDLL("libcuda.so.1").cuInit(0))'`
  (`0` means OK), or read `/proc/driver/nvidia/gpus/*/information`.

Without the toolkit, mount the driver libraries where the devShell scans for
them (`/run/opengl-driver/lib` is checked first) plus the device nodes:

```sh
podman run -d --name kernix --init --pull=newer \
  --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools \
  --device /dev/nvidia0 \
  -v /usr/lib64:/run/opengl-driver/lib:ro \
  -v /proc/driver/nvidia:/proc/driver/nvidia:ro \
  -e NIX_CONFIG='experimental-features = nix-command flakes' \
  docker.io/nixos/nix:latest sleep infinity
```

Use `/usr/lib/x86_64-linux-gnu` instead of `/usr/lib64` on Debian-family
hosts, and add `--device /dev/nvidiaN` for each additional GPU. The CUDA
`TORCH_CUDA_ARCH_LIST` is left unset by `nixtorch` so tools detect the device;
pin it per host only when one configuration must serve several architectures.

## CLI

```
kernix rebuild       rebuild and switch (default)
kernix boot          rebuild for next boot (NixOS only)
kernix test          activate without adding to boot menu (NixOS only)
kernix update        update flake inputs + rebuild
kernix cleanup [N]   remove old generations (keep N, default 5)
kernix list-gens     list generations
```

## Structure

```
flake.nix          host definitions, overlays, dev shells
hosts/             per-machine entry points
system/            OS-level modules (hardware, boot, GPU, desktop, services)
home/              user-level modules (terminal, desktop, apps)
overlays/          nixpkgs patches
cli/               rebuild scripts
lib/               shared options and helpers
```

The runtime theme engine and theme pack live in the separate
[kernix-theme](https://github.com/hinriksnaer/kernix-theme) flake (plus
`nixtorch`), consumed here as ordinary `github:` flake inputs pinned by
`flake.lock`. They used to be git submodules; the `github:` fetcher does not
populate submodules, which made the flake unevaluatable for any consumer
(`error: path '.../submodules/kernix-theme/flake.nix' does not exist`), so
they are plain inputs now. To iterate on one locally, override it:
`nix develop --override-input kernix-theme ../kernix-theme`. Theme wiring:
`home/theme/default.nix` (`kernix-theme.homeManagerModules.theme`).
