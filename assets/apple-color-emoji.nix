{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "apple-color-emoji";
  version = "18.4";
  dontUnpack = true;

  src = pkgs.fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/v${version}/AppleColorEmoji.ttf";
    hash = "sha256-pP0He9EUN7SUDYzwj0CE4e39SuNZ+SVz7FdmUviF6r0=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype
  '';

  meta = {
    description = "A derivation for the Apple Color Emoji font";
  };
}