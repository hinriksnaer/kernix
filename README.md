# kernix

NixOS configuration and CUDA development environment. Flake-based, multi-host,
with a runtime theme engine and declarative everything.

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

13 themes with runtime switching across hyprland, kitty, neovim, btop, waybar,
mako, rofi, and hyprlock. No rebuild required to switch.

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

- CUDA 12.9, cuDNN 9.13, GCC 14
- PyTorch env vars configurable via `projects.pytorch.env`
- All project settings in `settings.nix` under `hosts.<host>.nixtorch`

## Structure

```
settings.nix              single source of truth for all config
flake.nix                 hosts, overlays, formatter, nixtorch dev shell

modules/                  NixOS system modules
  core/                   base, zsh, nh, kernix-options
  desktop/                hyprland, fonts, desktop-session
  hardware/               gpu/{nvidia,intel,amd}, audio, bluetooth, networking
  apps/                   firefox, podman, proton-pass
  gaming/                 steam, gpu-extra

roles/                    module collections assigned to hosts
  core.nix                base system, zsh, nh
  desktop.nix             hyprland, fonts, session
  hardware.nix            GPU, audio, bluetooth, networking
  apps.nix                user applications

home/                     Home Manager configuration
  profiles/               per-host profiles (desktop, laptop, remote, container)
  collections/            module bundles (terminal, desktop, apps, gaming)
  modules/
    terminal/             neovim, zsh, git, tmux, cli-tools, ...
    desktop/              hyprland, monitors, rofi, waybar, ...
    emulators/            ghostty, kitty (via settings.terminal)
    theme/                theme engine + scripts

themes/                   13 color themes (per-app configs + wallpapers)
overlays/                 additions, flake-inputs, modifications
cli/                      kernix, kernix-hm-switch
```

## Infrastructure

- **nixtorch**: CUDA dev shell consumed as a flake input
- **Overlays**: custom packages via `pkgs.kernix-cli.*`, flake inputs via `pkgs.inputs'.*`
- **Dual channels**: `nixpkgs` (unstable) + `nixpkgs-stable` (25.05) for pinning
- **Formatter**: `nix fmt` (alejandra)
- **CI**: `nix flake check` + format check on push, weekly flake lock updates
- **nh**: diff display, nix-output-monitor, automatic GC (7d/5 gens)
- **Typed options**: `kernix.hosts` is a typed submodule, catches config errors at eval time
