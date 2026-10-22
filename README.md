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
git clone --recurse-submodules git@github.com:hinriksnaer/kernix.git ~/kernix
# Edit hosts/<hostname>/ -- set username, git identity, GPU, monitors
kernix rebuild
```

For containers (the host needs only podman + systemd, no nix) -- one flow for
the local machine and bare ssh servers alike, the host is just a parameter:

```sh
kernix container deploy              # local host
kernix container deploy user@server  # any ssh host, same image and unit

kernix container init                # first run only: deploy key, clone, switch
kernix container enter               # jump in (zsh once the profile is applied)

# inside the container, the usual workflow
kernix rebuild
```

`deploy` builds the image and the quadlet unit from the flake
(`nix build .#container-image .#container-quadlet`), loads the image into
podman, installs `~/.config/containers/systemd/kernix-dev.container`, and
hands the lifecycle to systemd (`systemctl --user status kernix-dev`). The
container runs as the unprivileged user `dev` (uid 1000), and nothing is
bind-mounted from the host -- the unit references only the image and the
named volumes `kernix-nix` (/nix) and `kernix-home` (/home/dev), which
seed from the image on first use and persist across redeploys, so `init`
runs once per host: it generates a read-only GitHub deploy key inside the
container (add the printed key at `github.com/<you>/kernix/settings/keys`),
clones the repo with the locked home-manager, and applies the
`dev@container` profile.
Thereafter config changes are `kernix rebuild` inside the container;
toolchain updates are `kernix container deploy` again. The image carries
only the bootstrap layer (nix, git, locked home-manager, bundled
`<nixpkgs>`), built with the Nix project's own `docker.nix` against kernix's
locked nixpkgs. For Kubernetes/OpenShift pods where the image is fixed,
install nix in the pod and apply the same profile with `home-manager switch`.

## CLI

```
kernix rebuild       rebuild and switch (default)
kernix boot          rebuild for next boot (NixOS only)
kernix test          activate without adding to boot menu (NixOS only)
kernix update        update flake inputs + rebuild
kernix cleanup [N]   remove old generations (keep N, default 5)
kernix list-gens     list generations
kernix container     manage the dev container: deploy | init | enter
                     (optional user@host; no host = local)
```

## Structure

```
flake.nix          host definitions, overlays, dev shells
hosts/             per-machine entry points
system/            OS-level modules (hardware, boot, GPU, desktop, services)
home/              user-level modules (terminal, desktop, apps)
submodules/        git submodules consumed as local flake inputs
overlays/          nixpkgs patches
cli/               rebuild scripts
lib/               shared options and helpers
```

The runtime theme engine and theme pack live in the separate
[kernix-theme](https://github.com/hinriksnaer/kernix-theme) flake (plus
`nixtorch`), consumed here as git submodules (clone with
`--recurse-submodules`, or run `git submodule update --init` in an existing
clone): `inputs.self.submodules = true`
fetches them with the repo, and the inputs are relative `path:` references
(`./submodules/...`), so uncommitted edits in a submodule apply directly on
rebuild -- no lock update, no commit (requires Nix >= 2.27). Theme wiring:
`home/theme/default.nix` (`kernix-theme.homeManagerModules.theme`).
