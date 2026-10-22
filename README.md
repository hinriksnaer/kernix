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

This repo ships no container tooling -- the flake is the interface. Any
container with Nix can apply the `dev@container` profile (`hosts/container/`):

```sh
podman run -d --restart=always --name kernix \
  -e NIX_CONFIG='experimental-features = nix-command flakes' \
  docker.io/nixos/nix:2.35.3

# copy the working tree in (no mounts; it is ~1MB now) and apply it
tar -c --exclude=.git --exclude=result . \
  | podman exec -i kernix tar -x -C /root/kernix
podman exec kernix nix run github:nix-community/home-manager -- \
  switch --flake /root/kernix#dev@container

podman exec -it kernix zsh -l      # thereafter `kernix rebuild` works inside
```

No volume over `/nix`: state lives in the container's writable layer and
survives stop/start/reboot. The flake is consumed from the working tree, so
uncommitted edits apply; point the same command at
`github:hinriksnaer/kernix#dev@container` instead to consume the published
version.

`dev@container` declares `home.username = "dev"`, so it must run as `dev`,
while the stock image runs as root. Either set `kernix.username = "root"` in
`hosts/container/default.nix` (simplest -- under rootless podman
container-root is your host uid, not host root), or bootstrap the user:
writable copies of `/etc/{passwd,group,shadow}`, a `dev` uid-1000 entry, and
`chown -R 1000:1000 /nix /home/dev`.

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
