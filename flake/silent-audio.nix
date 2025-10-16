{ lib, globals, username, pkgs, ... }: let
  # Import global variables
  globals = import ../nixos/globals.nix;
  username = globals.username;
in {
  systemd.user.services = {
    silent-audio = {
      Unit = {
        Description = "Silent Audio to Prevent HDA Failure";
      };
      Service = {
        ExecStart = "%h/.local/share/silent-audio/silent-audio.sh";
        Restart = "on-failure";
        RestartSec = "10s";
        Environment = "XDG_RUNTIME_DIR=%t";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  home.file = {
    ".local/share/silent-audio/silent-audio.sh" = {
      text = ''
        #!${pkgs.bash}/bin/bash

        while true; do
            # loop another audio asynchronously with 1 second delay to prevent speaker dying between the gaps
          sh -c "sleep 1; aplay /home/${username}/.local/share/silent-audio/silent.wav" &
          aplay /home/${username}/.local/share/silent-audio/silent.wav
        done
      '';
      executable = true;
    };
    ".local/share/silent-audio/silent.wav" = {
      source = ./silent-audio/silent.wav;
    };
  };
}