{
  description = "kernix - NixOS configuration. Chuck the system anywhere.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Tmux half of smart-splits.nvim v3 (source only; packaged via overlay,
    # Neovim half is a lazy.nvim dependency)
    smart-splits-backend-tmux = {
      url = "github:smart-splits-nvim/backend-tmux";
      flake = false;
    };
    # Ordinary flake inputs, NOT git submodules. The `github:` fetcher does
    # not populate submodules, so the previous `url = ./submodules/...` form
    # made this flake unevaluatable for any consumer:
    #   error: path '.../submodules/kernix-theme/flake.nix' does not exist
    # Both repos are public and pinned by flake.lock. To work on one locally:
    #   nix develop --override-input kernix-theme ../kernix-theme
    nixtorch = {
      url = "github:hinriksnaer/nixtorch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kernix-theme = {
      url = "github:hinriksnaer/kernix-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix project source -- provides docker.nix, the image builder behind
    # the official nixos/nix containers. Pinned so its (internal)
    # interface only changes when this input is bumped.
    nix.url = "github:NixOS/nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    llm-agents,
    nixtorch,
    kernix-theme,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;

    # ── Package sets ──

    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgsUnfree = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };

    # ── Host builders ──

    mkHost = hostname:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          # Host declaration (sets kernix.* options)
          ./hosts/${hostname}

          # System modules (gate themselves via kernix.*.enable)
          ./system/core
          ./system/desktop
          ./system/hardware
          ./system/apps
          ./system/gaming

          # Home Manager integration
          home-manager.nixosModules.home-manager
          ({config, ...}: {
            nixpkgs.overlays = builtins.attrValues self.overlays;
            networking.hostName = "kernix-${hostname}";

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              extraSpecialArgs = {
                host = config.kernix;
                inherit hostname;
                inherit kernix-theme;
              };
              users.${config.kernix.username} =
                import ./home {inherit hostname;};
            };
          })
        ];
      };

    # Evaluate a host module through the option schema to extract config.
    # Works for any host that doesn't import NixOS-only modules
    # (hardware-configuration.nix, etc.).
    evalHost = hostName: let
      evaluated = lib.evalModules {
        modules = [
          ./lib/options.nix
          (import ./hosts/${hostName})
        ];
      };
    in
      evaluated.config.kernix;

    # Standalone HM hosts (no NixOS/Darwin system config).
    hmOnlyHostNames = ["remote" "container" "fedora"];
  in {
    # ── Formatter (nix fmt) ──
    formatter.${system} = pkgs.alejandra;

    # ── Overlays ──
    overlays = import ./overlays {inherit inputs;};

    # ── Custom packages (nix build .#<name>) ──
    packages.${system} = {
      inherit (pkgsUnfree.kernix-cli) kernix;
    };

    # ── One-command apply: nix run .#<user>@<host> ──
    # The host config is just the attribute; no clone, no separate
    # home-manager flake URL. Equivalent to
    #   home-manager switch --flake <this flake>#<user>@<host>
    # Must run as the profile's user: home-manager sanity-checks $USER,
    # $HOME and uid against the configuration.
    apps.${system} =
      builtins.mapAttrs (name: _: {
        type = "app";
        program = "${pkgs.writeShellScript "kernix-switch-${name}" ''
          exec ${home-manager.packages.${system}.home-manager}/bin/home-manager switch \
            --flake '${toString self}#${name}' "$@"
        ''}";
      })
      self.homeConfigurations;

    # ── Machine configurations ──
    nixosConfigurations = {
      desktop = mkHost "desktop";
      laptop = mkHost "laptop";
    };

    # ── Home Manager (standalone, user@host convention) ──
    homeConfigurations = builtins.listToAttrs (map (hostName: let
      hostCfg = evalHost hostName;
    in
      lib.nameValuePair
      "${hostCfg.username}@${hostName}"
      (home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsUnfree;
        extraSpecialArgs = {
          host = hostCfg;
          hostname = hostName;
          inherit kernix-theme;
        };
        modules = [
          (import ./home {hostname = hostName;})
        ];
      }))
    hmOnlyHostNames);

    # ── Development shells ──
    devShells.${system} = let
      # NixOS hosts: extract kernix config from the already-built system.
      nixosHostConfigs =
        lib.mapAttrs
        (_: sys: sys.config.kernix)
        self.nixosConfigurations;
      # Standalone hosts: evaluate through the option schema.
      hmHostConfigs = lib.genAttrs hmOnlyHostNames evalHost;
      # Merge and filter to hosts with nixtorch config.
      allConfigs = nixosHostConfigs // hmHostConfigs;
      withNixtorch = lib.filterAttrs (_: cfg: cfg.nixtorch != {}) allConfigs;
    in
      lib.mapAttrs
      (_: cfg: nixtorch.lib.mkDevShell cfg.nixtorch)
      withNixtorch;
  };
}
