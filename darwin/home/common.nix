{ username, hostname }:

{ config, lib, ... }:

{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "26.05";
  };

  imports = [
    (import ./fish.nix { inherit hostname; })
    ./git.nix
    ./iterm2.nix
    ./karabiner.nix
  ];

  fonts.fontconfig.enable = true;
}
