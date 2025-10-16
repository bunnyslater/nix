{
  description = "Billie's Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }:
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
      # Import global variables.
      globals = import ../nixos/globals.nix;
      username = globals.username;
      hostname = globals.hostname;
    in {
      nixosConfigurations = {
        "${hostname}" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ../nixos/hardware/${hostname}.nix
            ../nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.users.${username} = {
                imports = [ ./home.nix ./flatpak.nix ];
              };
              home-manager.extraSpecialArgs = { inherit plasma-manager; };
              home-manager.backupFileExtension = "backup";
            }
          ];
        };
      };
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ./flatpak.nix plasma-manager.homeModules.plasma-manager ];
        };
      };
      packages.x86_64-linux = {
        apple-color-emoji = pkgs.apple-color-emoji;
      };
    };
}
