{ pkgs, username, ... }:

let
  # RetinaScale v2.0.0 - Display scaling utility
  retinascale = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "RetinaScale";
    version = "2.0.0";
    src = pkgs.fetchurl {
      url = "https://github.com/itsabhishekolkha/RetinaScale/releases/download/v${version}/RetinaScale.${version}.dmg";
      sha256 = "1lawvpb95hdzbkpjkf9amr9rphfanzzdhz7nxq0a87ppv82x6662";
    };
    nativeBuildInputs = [ pkgs.undmg ];
    sourceRoot = "RetinaScale.app";
    installPhase = ''
      mkdir -p $out/Applications
      cp -r . $out/Applications/RetinaScale.app
    '';
  };

  # iloader v2.2.5 - iOS sideloading utility
  iloader = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "iloader";
    version = "2.2.5";
    src = pkgs.fetchurl {
      url = "https://github.com/nab138/iloader/releases/download/v${version}/iloader-darwin-universal.dmg";
      sha256 = "1rzs7yigf8fhyhq8vyb9nyd6lz2mjs5haw8gl3054p048x2nqgm0";
    };
    nativeBuildInputs = [ pkgs.undmg ];
    sourceRoot = "iloader.app";
    installPhase = ''
      mkdir -p $out/Applications
      cp -r . $out/Applications/iloader.app
    '';
  };
in
{
  # Install GitHub release apps via environment.systemPackages
  # These will be linked to /Applications/Nix Apps/
  environment.systemPackages = [ retinascale iloader ];
}
