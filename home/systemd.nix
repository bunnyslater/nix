{ lib, pkgs, ... }: let
in {
  # Configures systemd user services.
  # autostart-* runs programs at login.
  systemd.user.services = {
    autostart-1password = {
      Unit = {
        Description = "Start 1Password (silently) at login";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs._1password-gui} --silent";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    autostart-nextcloud = {
      Unit = {
        Description = "Start Nextcloud at login";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.nextcloud-client}";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    autostart-signal-desktop = {
      Unit = {
        Description = "Start Signal Desktop at login";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.flatpak} run --user org.signal.Signal";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}