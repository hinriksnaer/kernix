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
    nixtorch.url = "github:hinriksnaer/nixtorch";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    llm-agents,
    nixtorch,
    ...
  } @ inputs: let
    lib = nixpkgs.lib;
    settings = import ./settings.nix;

    # ── Package sets ──

    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgsUnfree = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };

    darwinSystem = "aarch64-darwin";
    pkgsDarwin = import nixpkgs {
      system = darwinSystem;
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };

    # ── Shared modules ──

    commonModules = [
      {kernix = settings;}
      {nixpkgs.overlays = builtins.attrValues self.overlays;}
    ];

    # Home Manager integration (works for both NixOS and Darwin).
    mkHmModule = hmModule: hostname: {
      imports = [hmModule];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
      home-manager.users.${settings.hosts.${hostname}.username} =
        import ./home {inherit hostname settings;};
    };

    # ── Host builders ──

    mkHost = hostname:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          commonModules
          ++ [
            ./hosts/${hostname}/system.nix
            (mkHmModule home-manager.nixosModules.home-manager hostname)
          ];
      };

    mkDarwinHost = hostname:
      nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = {inherit settings;};
        modules =
          commonModules
          ++ [
            ./hosts/${hostname}/system.nix
            (mkHmModule home-manager.darwinModules.home-manager hostname)
          ];
      };
  in {
    # ── Formatter (nix fmt) ──
    formatter.${system} = pkgs.alejandra;

    # ── Overlays ──
    overlays = import ./overlays {inherit inputs;};

    # ── Custom packages (nix build .#<name>) ──
    packages.${system} = {
      inherit (pkgsUnfree.kernix-cli) kernix;
    };

    # ── Machine configurations ──
    nixosConfigurations = {
      desktop = mkHost "desktop";
      laptop = mkHost "laptop";
    };

    # ── Darwin (macOS) configurations ──
    darwinConfigurations = {
      macbook = mkDarwinHost "macbook";
    };

    # ── Home Manager (standalone, user@host convention) ──
    homeConfigurations =
      lib.mapAttrs'
      (
        hostName: hostCfg:
          lib.nameValuePair
          "${hostCfg.username}@${hostName}"
          (home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsUnfree;
            modules = [
              (import ./home {
                hostname = hostName;
                inherit settings;
              })
            ];
          })
      )
      settings.hosts;

    # ── Development shells ──
    devShells.${system}.default =
      nixtorch.lib.mkDevShell settings.hosts.container.nixtorch;
    devShells.${darwinSystem}.default =
      import ./hosts/macbook/devshell.nix {pkgs = pkgsDarwin;};
  };
}
