{
  description = "kernix - NixOS configuration. Chuck the system anywhere.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixtorch.url = "github:hinriksnaer/nixtorch";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nix-darwin,
    nixtorch,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    darwinSystem = "aarch64-darwin";

    pkgs = nixpkgs.legacyPackages.${system};
    pkgsUnfree = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };
    pkgsDarwin = import nixpkgs {
      system = darwinSystem;
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };
    lib = nixpkgs.lib;

    # User settings (plain attrset, assigned to config.kernix.*)
    settings = import ./settings.nix;

    # Hosts that run on darwin (used to select the right pkgs)
    darwinHosts = ["macbook"];
    pkgsForHost = hostname:
      if builtins.elem hostname darwinHosts
      then pkgsDarwin
      else pkgsUnfree;

    # Common modules: settings + base config (imported by all machines)
    commonModules = [
      {kernix = settings;}
    ];

    # Auto-discover .nix files from a directory
    discoverModules = dir:
      lib.mapAttrs'
      (
        name: _:
          lib.nameValuePair
          (lib.removeSuffix ".nix" name)
          (import (dir + "/${name}"))
      )
      (
        lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name)
        (builtins.readDir dir)
      );

    # Auto-discover directories with default.nix
    discoverDirs = dir:
      lib.mapAttrs'
      (name: _: lib.nameValuePair name (import (dir + "/${name}")))
      (
        lib.filterAttrs
        (name: type: type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
        (builtins.readDir dir)
      );

    # Stable channel for pinning reliability-sensitive packages
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    # Home Manager NixOS integration -- auto-applies HM on nixos-rebuild switch.
    hmNixosModule = hostname: {
      imports = [home-manager.nixosModules.home-manager];
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-backup";
      home-manager.extraSpecialArgs = {inherit pkgs-stable;};
      home-manager.users.${settings.hosts.${hostname}.username} =
        import ./home {inherit hostname settings;};
    };
  in {
    # ── Formatter (nix fmt) ──
    formatter.${system} = pkgs.alejandra;
    formatter.${darwinSystem} = pkgsDarwin.alejandra;

    # ── Overlays ──
    overlays = import ./overlays {inherit inputs;};

    # ── Custom packages (nix build .#<name>) ──
    packages.${system} = {
      inherit (pkgsUnfree.kernix-cli) kernix;
    };

    # ── Individually importable modules (auto-discovered) ──
    nixosModules = let
      discoverAll = dir: (discoverModules dir) // (discoverDirs dir);
    in
      (discoverAll ./modules/core)
      // (discoverAll ./modules/desktop)
      // (discoverAll ./modules/hardware)
      // (discoverAll ./modules/apps)
      // (discoverAll ./modules/gaming)
      // (discoverModules ./roles);

    # ── Machine configurations ──
    nixosConfigurations = let
      mkHost = hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {inherit inputs;};
          modules =
            commonModules
            ++ [
              ./hosts/${hostname}/default.nix
              (hmNixosModule hostname)
              {nixpkgs.overlays = builtins.attrValues self.overlays;}
            ];
        };
    in {
      desktop = mkHost "desktop";
      laptop = mkHost "laptop";
    };

    # ── Home Manager (standalone, user@host convention) ──
    homeConfigurations =
      lib.mapAttrs'
      (
        hostName: hostCfg:
          lib.nameValuePair
          "${hostCfg.username}@${hostName}"
          (home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsForHost hostName;
            modules = [
              (import ./home {
                hostname = hostName;
                inherit settings;
              })
            ];
          })
      )
      settings.hosts;

    # ── Darwin configurations ──
    darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
      system = darwinSystem;
      modules = [
        ./hosts/macbook/default.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.users.${settings.hosts.macbook.username} = import ./home {
            hostname = "macbook";
            inherit settings;
          };
        }
        {nixpkgs.overlays = builtins.attrValues self.overlays;}
      ];
    };

    # ── Development shells (powered by nixtorch) ──
    devShells.${system}.default =
      nixtorch.lib.mkDevShell settings.hosts.container.nixtorch;
  };
}
