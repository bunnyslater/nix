{
  description = "Billie's Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, nixpkgs-unstable, home-manager, plasma-manager, nix-flatpak, nix-darwin, nix-homebrew, ... }:
    let
      system = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      darwinHostname = "bs-Virtual-Machine";
      darwinUsername = "b";
      appleColorEmojiOverlay = final: prev: {
        apple-color-emoji = final.callPackage ./modules/apple-color-emoji.nix { };
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ appleColorEmojiOverlay ];
      };
      mkWorkstation =
        { deviceModule, hmImports }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; pkgs_unstable = pkgs-unstable; };
          modules = [
            deviceModule
            home-manager.nixosModules.home-manager
            nix-flatpak.nixosModules.nix-flatpak
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; pkgs_unstable = pkgs-unstable; };
                users.billie = {
                  imports = hmImports;
                };
              };
            }
          ];
        };
    in 
      {
        nixosConfigurations = {
          vm = mkWorkstation {
            deviceModule = ./hardware/vm/default.nix;
            hmImports = [
              ./home/common.nix
              ./home/gnome.nix
              ./home/systemd.nix
            ];
          };
          chiot = mkWorkstation {
            deviceModule = ./hardware/chiot/default.nix;
            hmImports = [
              ./home/common.nix
              ./home/gnome.nix
            ];
          };
          hermine = mkWorkstation {
            deviceModule = ./hardware/hermine/default.nix;
            hmImports = [
              ./home/common.nix
              ./home/gnome.nix
              ./home/systemd.nix
              ./home/silent-audio/silent-audio.nix
            ];
          };
          x390 = mkWorkstation {
            deviceModule = ./hardware/x390/default.nix;
            hmImports = [
              ./home/common.nix
              ./home/gnome.nix
            ];
          };
        };
        packages.x86_64-linux = {
          apple-color-emoji = pkgs.apple-color-emoji;
        };

        darwinConfigurations."bs-Virtual-Machine" = nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = inputs // {
            username = darwinUsername;
            hostname = darwinHostname;
          };
          modules = [
            nix-homebrew.darwinModules.nix-homebrew
            home-manager.darwinModules.home-manager
            ./darwin/nix-core.nix
            ./darwin/system.nix
            ./darwin/apps.nix
            ./darwin/homebrew.nix
            ./darwin/host-users.nix
            ./darwin/home.nix
          ];
        };
    };
}
