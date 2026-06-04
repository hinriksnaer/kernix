# kernix

One Nix flake that manages every machine -- from a multi-GPU desktop to a
Kubernetes container. Clone, set your identity in `settings.nix`, rebuild.

## Architecture

### Hardware targets

A single repo produces five host configurations, each composed from the
same shared module library:

| Host | Platform | System layer | Use case |
|---|---|---|---|
| `desktop` | NixOS `x86_64` | Full NixOS + Home Manager | Nvidia GPU, multi-monitor workstation |
| `laptop` | NixOS `x86_64` | Full NixOS + Home Manager | Intel, power management, Meteor Lake |
| `macbook` | Darwin `aarch64` | nix-darwin + Home Manager | Apple Silicon, local dev shell |
| `remote` | Linux | Home Manager only | Headless server |
| `container` | Linux | Home Manager only | Kubernetes/OpenShift, CUDA dev |

Full hosts (`desktop`, `laptop`, `macbook`) get OS-level configuration --
boot, networking, GPU drivers, display server. Headless hosts (`remote`,
`container`) get only user-level tooling via Home Manager, making them
portable to any Linux with Nix installed.

### Layered composition

Configuration is split into two layers that compose independently:

- **`system/`** -- OS-level NixOS and Darwin modules: hardware, boot, GPU
  drivers, system services. Only imported by hosts that manage the full OS.
- **`home/`** -- User-level Home Manager modules: terminal, desktop,
  applications, themes. Portable across all hosts regardless of OS.

Each host in `hosts/` selectively imports the modules it needs. A desktop
gets both layers; a container gets only `home/`. Adding a new machine means
writing a thin host file that picks from existing modules.

### Single source of truth

All per-host settings -- usernames, GPU type, monitor layout, git identity,
CUDA config -- live in `settings.nix`. A typed NixOS module
(`kernix-options.nix`) validates the full attrset at eval time, so
misconfigurations fail fast with clear errors instead of silently producing
a broken system.

### Overlays as escape hatches

Upstream nixpkgs fixes live in `overlays/`, one file per patch. When a
package breaks (EOL Electron, linker issues), the fix is a single file
that's easy to add and easy to drop once upstream catches up.

## Quick Start

NixOS hosts:

```sh
git clone git@github.com:hinriksnaer/kernix.git ~/kernix
# Edit settings.nix -- set username, git identity, GPU, monitors
kernix rebuild
```

Container (Kubernetes/OpenShift):

```sh
export USER=root
git clone git@github.com:hinriksnaer/kernix.git ~/kernix
nix run home-manager/master -- switch --flake ~/kernix#root@container -b backup
```

## CLI

### kernix (NixOS hosts)

```
kernix rebuild       Rebuild and switch (nh os switch with diff display)
kernix boot          Rebuild for next boot (safer for session changes)
kernix test          Activate without adding to boot menu
kernix update        Update flake inputs + rebuild
kernix cleanup [N]   Remove old generations (keep N, default 5)
kernix list-gens     List system generations
```

### kernix-hm-switch (remote/container)

Pulls latest config, updates all flake inputs (including nixtorch), and
applies Home Manager:

```sh
kernix-hm-switch
```

### nixtorch (dev shell)

Available inside `nix develop ~/kernix`:

```
nixtorch build [--force] [projects...]   Clone + build from source
nixtorch status                          Show environment and project state
nixtorch update                          Update nixtorch and re-enter shell
nixtorch update <projects...>            Pull latest code and rebuild
nixtorch clean [projects...]             Remove repos, markers, venv
```

## Configuration

All settings live in `settings.nix` -- the single source of truth:

```nix
{
  defaultTheme = "ayu-dark";
  git = { name = "..."; email = "..."; };

  hosts = {
    desktop = {
      username = "softmax";
      gpu = "nvidia";
      monitors = [
        { name = "HDMI-A-1"; resolution = "7680x2160@120"; scale = 1.5; primary = true; }
      ];
    };

    container = {
      username = "root";
      # Passed directly to nixtorch.lib.mkDevShell
      nixtorch = {
        cudaVisibleDevices = "";
        workspace = "$HOME/workspace";
        projects = {
          pytorch = { cudaArch = "9.0"; maxJobs = 32; };
          helion = { torchIndex = "nightly/cu130"; backends = ["cute"]; };
        };
      };
    };
  };
}
```

Host options are type-checked via `kernix-options.nix`. The `nixtorch` config
is passed directly to `nixtorch.lib.mkDevShell` -- the attrset shape matches
the function signature.

## Container Setup

### Bootstrap (once per container)

```sh
export USER=root
git clone git@github.com:hinriksnaer/kernix.git ~/kernix
nix run home-manager/master -- switch --flake ~/kernix#root@container -b backup
```

This installs Home Manager, terminal tools (neovim, zsh, tmux), direnv,
and sets up the nixtorch dev shell.

### Entering the dev shell

```sh
nix develop ~/kernix
nixtorch build pytorch
```

### Updating

```sh
kernix-hm-switch
```

This pulls the latest kernix config, updates all flake inputs (nixpkgs,
home-manager, nixtorch), and applies Home Manager in one command.

### Note on USER

The container image may not set the `USER` environment variable. If
`home-manager switch` fails with `USER: unbound variable`, run
`export USER=root` first. After the initial setup, the container profile
sets `USER` automatically in `.bashrc`.

## Themes

13 themes with runtime switching across hyprland, ghostty, neovim, btop, waybar,
mako, rofi, hyprlock, and opencode. No rebuild required to switch.

```
Super+T          Theme picker (rofi)
Super+Shift+T    Next theme
Super+W          Wallpaper picker
Super+Shift+W    Next wallpaper
kernix-theme     Interactive fzf selector (terminal)
```

## CUDA Development

The dev shell is powered by [nixtorch](https://github.com/hinriksnaer/nixtorch),
consumed as a flake input. Configuration lives in `settings.nix` under the
`nixtorch` key and is passed directly to `nixtorch.lib.mkDevShell`.

```sh
nix develop ~/kernix           # enter dev shell
nixtorch build pytorch         # clone + build PyTorch from source
nixtorch build helion          # clone + build Helion compiler
nixtorch status                # show environment + project state
```

- CUDA 13, cuDNN, GCC (versions from nixtorch flake input)
- PyTorch env vars configurable via `projects.pytorch.env`
- All project settings in `settings.nix` under `hosts.<host>.nixtorch`

## Structure

```
settings.nix       all per-host config (usernames, GPU, monitors, nixtorch)
flake.nix          host definitions, overlays, dev shells
system/            OS-level modules: hardware, boot, GPU, desktop, services
home/              user-level modules: terminal, desktop, apps, themes
hosts/             per-machine entry points (imports from system/ and home/)
themes/            13 color themes (per-app configs + wallpapers)
overlays/          nixpkgs additions and per-package patches
cli/               kernix, kernix-hm-switch, kernix-darwin-switch
```

## Infrastructure

- **Channel**: nixpkgs unstable
- **CI**: `nix flake check` + `nix fmt` on push; weekly `flake.lock` updates via PR
- **Formatter**: alejandra
- **nh**: diff display, nix-output-monitor, automatic GC (7d / 5 gens)
