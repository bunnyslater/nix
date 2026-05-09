{ username, hostname }:

{ config, lib, ... }:

{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "25.11";
  };

  imports = [
    (import ./fish.nix { inherit hostname; })
    ./iterm2.nix
    ./karabiner.nix
  ];

  fonts.fontconfig.enable = true;
}
