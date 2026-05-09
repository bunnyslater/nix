{ pkgs, lib, ... }: {
  nix = {
    # Set to false if using Determinate Nix, which manages its own daemon.
    enable = true;

    package = pkgs.nix;

    settings = {
      experimental-features = [ "nix-command" "flakes" ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      builders-use-substitutes = true;

      # Disabled: https://github.com/NixOS/nix/issues/7273
      auto-optimise-store = false;
    };

    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
