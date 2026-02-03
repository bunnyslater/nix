{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.workstation.plasma;
in
{
  options.workstation.plasma.enable = lib.mkEnableOption "KDE Plasma-based workstation environment";

  config = lib.mkIf cfg.enable {
    services = {
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        defaultSession = "plasma";
      };
      desktopManager = {
        plasma6.enable = true;
      };
    };

    environment = {
      sessionVariables = {
        GTK_THEME = "Breeze";
      };
    };
    
  };
}
