{ config, lib, pkgs, globals, ... }:

lib.mkIf globals.enableGnome {
  # Configure Gnome desktop environment settings
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      cursor-theme = "Adwaita";
      color-scheme = "prefer-dark";
      accent-color = "purple";
      font-name = "Adwaita Sans 11";
      show-battery-percentage = true;
    };
    "org/gnome/desktop/background" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/sheet-l.jxl";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/sheet-d.jxl";
      primary-color = "#1a5fb4";
      secondary-color = "#000000";
    };
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Shift><Super>q" ];
      minimize = "<Shift>m";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Alt>t";
      command = "${lib.getExe pkgs.ptyxis}";
      name = "Launch Ptyxis";
    };
    "org/gnome/desktop/wm/preferences" = {
      resize-with-right-button = true;
    };
    "org/gnome/shell" = {
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "blur-my-shell@aunetx"
      ];
    };
};

  # Ensure themes and extensions are available
  home.packages = with pkgs; [
    gnome-shell-extensions
    gnomeExtensions.blur-my-shell
    libadwaita
    adwaita-qt
    adwaita-qt6
    ptyxis
    gnome-themes-extra
    adwaita-icon-theme
    adwaita-icon-theme-legacy
  ];
}
