{
  description = "hawker - NixOS configuration. Chuck the system anywhere.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgsUnfree = import nixpkgs { inherit system; config.allowUnfree = true; };
      lib = nixpkgs.lib;

      # Common modules: user settings (imported by all machine configs)
      commonModules = [
        ./settings.nix
      ];

      # Per-host settings (read directly, not through module system)
      settings = (import ./settings.nix { }).hawker;

      # Auto-discover .nix files from a directory
      discoverModules = dir:
        lib.mapAttrs'
          (name: _: lib.nameValuePair
            (lib.removeSuffix ".nix" name)
            (import (dir + "/${name}"))
          )
          (lib.filterAttrs
            (name: type: type == "regular" && lib.hasSuffix ".nix" name)
            (builtins.readDir dir)
          );

      # Auto-discover directories with default.nix
      discoverDirs = dir:
        lib.mapAttrs'
          (name: _: lib.nameValuePair name (import (dir + "/${name}")))
          (lib.filterAttrs
            (name: type: type == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
            (builtins.readDir dir)
          );

      # Home Manager NixOS integration -- auto-applies HM on nixos-rebuild switch.
      hmNixosModule = hostname: {
        imports = [ home-manager.nixosModules.home-manager ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.users.${settings.hosts.${hostname}.username} =
          import ./home { inherit hostname settings; };
      };

    in {

      # ── Formatter (nix fmt) ──
      formatter.${system} = pkgs.alejandra;

      # ── Overlays ──
      overlays = import ./overlays { inherit inputs; };

      # ── Custom packages (nix build .#<name>) ──
      packages.${system} = let
        cli = import ./cli { inherit pkgs; };
      in {
        inherit (cli) hawker-switch hawker-dev;
      };

      # ── Individually importable modules (auto-discovered) ──
      nixosModules = let
        discoverAll = dir: (discoverModules dir) // (discoverDirs dir);
      in
        (discoverAll ./modules/core) //
        (discoverAll ./modules/desktop) //
        (discoverAll ./modules/hardware) //
        (discoverAll ./modules/apps) //
        (discoverAll ./modules/gaming) //
        (discoverModules ./roles);

      # ── Machine configurations ──
      nixosConfigurations = let
        mkHost = hostname: nixpkgs.lib.nixosSystem {
          inherit system;
          modules = commonModules ++ [
            ./hosts/${hostname}/default.nix
            (hmNixosModule hostname)
            { nixpkgs.overlays = builtins.attrValues self.overlays; }
          ];
        };
      in {
        desktop = mkHost "desktop";
        laptop = mkHost "laptop";
      };

      # ── Home Manager (standalone, user@host convention) ──
      homeConfigurations = lib.mapAttrs'
        (hostName: hostCfg: lib.nameValuePair
          "${hostCfg.username}@${hostName}"
          (home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsUnfree;
            modules = [
              (import ./home { hostname = hostName; inherit settings; })
            ];
          })
        ) settings.hosts;

      # ── Development shells ──
      devShells.${system}.default = import ./dev/shell.nix {
        pkgs = pkgsUnfree;
        inherit settings;
      };
    };
}
