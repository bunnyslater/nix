{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.gnome;
in
{
  options.workstation.gnome.enable = lib.mkEnableOption "GNOME-based workstation environment";

  config = lib.mkIf cfg.enable {
    services = {
      displayManager = {
        gdm = {
          enable = true;
        };
        defaultSession = "gnome";
      };
      desktopManager = {
        gnome = { 
          enable = true;
          extraGSettingsOverrides = ''
            [org.gnome.mutter]
            experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
          '';
        };
      };
    };

    environment = {
      gnome = {
        excludePackages = with pkgs; [
          gnome-tour
          gnome-user-docs
          geary
          gnome-weather
          gnome-contacts
          simple-scan
          totem
          gnome-connections
          yelp
          gnome-maps
          epiphany
          decibels
          gnome-music
          showtime
          gnome-calendar
        ];
      };
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
    };
    
  };
}
