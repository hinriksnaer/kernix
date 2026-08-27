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
| `container` | Linux | Home Manager only | Kubernetes/OpenShift, CUDA dev |
| `fedora` | Fedora Linux | Home Manager only | Hyprland via Nix on Fedora |

Full hosts get OS-level config (boot, GPU drivers, networking). Headless hosts get user-level tooling only, portable to any Linux with Nix.

## Key Features

**Layered composition** -- `system/` handles OS-level modules (hardware, boot, GPU drivers, services), `home/` handles user-level modules (terminal, desktop, apps, themes). Each host picks what it needs. Adding a machine is a thin config file.

**Type-checked settings** -- All per-host options (GPU, monitors, git identity, CUDA config) are validated by typed NixOS modules. Bad config fails at eval, not at runtime.

**Runtime theme switching** -- 11+ themes that propagate across Hyprland, Ghostty, Neovim, btop, Waybar, mako, rofi, and hyprlock with no rebuild. `Super+T` to pick, `Super+Shift+T` to cycle.

**CUDA dev shells** -- Powered by [nixtorch](https://github.com/hinriksnaer/nixtorch). Build PyTorch and Helion from source with configurable CUDA architectures. Direnv auto-activates the shell.

**Gaming** -- Steam with Proton, Gamescope sessions, Sunshine remote play, couch mode with TV output.

**Terminal stack** -- Zsh with vi-mode, tmux with sessionizer, Neovim with tree-sitter/LSP/Copilot, lazygit, yazi, fzf, zoxide, starship, and more.

## Quick Start

```sh
git clone git@github.com:hinriksnaer/kernix.git ~/kernix
# Edit settings.nix -- set username, git identity, GPU, monitors
kernix rebuild
```

For containers:

```sh
export USER=root
git clone git@github.com:hinriksnaer/kernix.git ~/kernix
nix run home-manager/master -- switch --flake ~/kernix#root@container -b backup
```

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
home/              user-level modules (terminal, desktop, apps, themes)
themes/            color themes with per-app configs + wallpapers
overlays/          nixpkgs patches
cli/               rebuild scripts
lib/               shared options and helpers
```
