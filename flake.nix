{
  description = "Billie's Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";

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

  };

  outputs = inputs@{ nixpkgs, home-manager, plasma-manager, nix-flatpak, ... }:
    let
      system = "x86_64-linux";
      appleColorEmojiOverlay = final: prev: {
        apple-color-emoji = final.callPackage ./assets/apple-color-emoji.nix { };
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
          specialArgs = { inherit inputs; };
          modules = [
            deviceModule
            home-manager.nixosModules.home-manager
            nix-flatpak.nixosModules.nix-flatpak
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; };
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
        };
        packages.x86_64-linux = {
          apple-color-emoji = pkgs.apple-color-emoji;
        };
    };
}
