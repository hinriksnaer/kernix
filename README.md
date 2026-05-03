# kernix

NixOS configuration and CUDA development environment. Flake-based, multi-host,
with a runtime theme engine and declarative everything.

## Quick Start

```bash
# NixOS hosts
git clone git@github.com:hinriksnaer/kernix.git ~/kernix
# Edit settings.nix -- set username, git identity, GPU, monitors
kernix rebuild

# Remote dev hosts (non-NixOS)
nix develop ~/kernix
kernix-dev build pytorch
```

## CLI

```
kernix rebuild       Rebuild and switch (nh os switch with diff display)
kernix boot          Rebuild for next boot (safer for session changes)
kernix test          Activate without adding to boot menu
kernix update        Update flake inputs + rebuild
kernix cleanup [N]   Remove old generations (keep N, default 5)
kernix list-gens     List system generations
```

## Configuration

All settings live in `settings.nix` -- the single source of truth:

```nix
kernix = {
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
    laptop = {
      username = "hgudmund";
      gpu = "intel";
      monitors = [{ name = ""; resolution = "preferred"; scale = 1.0; primary = true; }];
    };
  };
};
```

All host options are type-checked via `kernix-options.nix`. Typos and wrong types
are caught at evaluation time.

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

## Structure

```
settings.nix              single source of truth for all config
flake.nix                  2 hosts, overlays, formatter, dev shell

modules/                   NixOS system modules
  core/                    base, zsh, nh, kernix-options
  desktop/                 hyprland, fonts, desktop-session
  hardware/                gpu/{nvidia,intel,amd}, audio, bluetooth, networking
  apps/                    firefox, podman, proton-pass
  gaming/                  steam, gpu-extra

roles/                     module collections assigned to hosts
  core.nix                 base system, zsh, nh
  desktop.nix              hyprland, fonts, session
  hardware.nix             GPU, audio, bluetooth, networking
  apps.nix                 user applications

home/                      Home Manager configuration
  profiles/                per-host profiles (desktop, laptop, remote)
  collections/             module bundles (terminal, desktop, apps, gaming)
  modules/
    terminal/
      neovim/              default.nix + config/ (Lua config)
      zsh.nix, git.nix, tmux.nix, cli-tools.nix, ...
    desktop/
      hyprland.nix, monitors.nix, kitty.nix, rofi.nix, ...
      waybar/              default.nix + config/style.css
    theme/
      default.nix          theme engine + hook registrations
      desktop.nix          wallpaper/rofi theme scripts
      scripts/             all theme scripts (bash, writeShellApplication)

themes/                    13 color themes (per-app configs + wallpapers)
overlays/                  additions, flake-inputs, modifications
cli/                       kernix, kernix-dev, kernix-hm-switch
dev/                       CUDA development shell
  shell.nix                entry point (nix develop / direnv)
  base/                    shared tooling + CUDA base layer
  projects/                per-project modules (pytorch, helion, vllm)
```

## Infrastructure

- **Overlays**: custom packages via `pkgs.kernix-cli.*`, flake inputs via `pkgs.inputs'.*`
- **Dual channels**: `nixpkgs` (unstable) + `nixpkgs-stable` (25.05) for pinning
- **Formatter**: `nix fmt` (alejandra)
- **Registry pinning**: `nix run nixpkgs#foo` uses the system's pinned nixpkgs
- **CI**: `nix flake check` + format check on push, weekly flake lock updates
- **nh**: diff display, nix-output-monitor, automatic GC (7d/5 gens)
- **Typed options**: `kernix.hosts` is a typed submodule, catches config errors at eval time
- **Monitors option**: `config.monitors` typed HM option, fed from settings.nix

## CUDA Development

```bash
nix develop ~/kernix         # enter dev shell
kernix-dev build pytorch     # clone + build PyTorch from source
kernix-dev build helion      # clone + build Helion compiler
kernix-dev status            # show project build status
```

- CUDA 12.9, cuDNN 9.13, GCC 14
- `CMAKE_PREFIX_PATH` set for cmake discovery
- direnv integration (auto-enters shell in project dirs)
- All project settings in `settings.nix` under `hosts.remote.projects`
