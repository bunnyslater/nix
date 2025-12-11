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
      minimize = [ "<Super>m" ];
      switch-applications = [];
      switch-applications-backward = [];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
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
        "caffeine@patapon.info"
        "hotedge@jonathan.jdoda.ca"
        "display-adjustment@w8jcik.gitlab.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "emoji-copy@felipeftn"
        "just-perfection-desktop@just-perfection"
        "appnameindicator@dev64.xyz"
        "unblank@sun.wxg@gmail.com"
        "middleclickclose@paolo.tranquilli.gmail.com"
        "clipboard-indicator@tudmotu.com"
      ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
        "1password.desktop"
        "org.gnome.Ptyxis.desktop"
        "org.gnome.Settings.desktop"
        "apple-notes.desktop"
        "org.signal.Signal.desktop"
        "virt-manager.desktop"
        "chromium-vopono.desktop"
        "anki.desktop"
        "code.desktop"
      ];
    };
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ "<Shift><Super>s" ];
    };
    "org/gnome/shell/extensions/hot-edge" = {
      show-animation = false;
    };
    "org/gnome/shell/extensions/just-perfection" = {
      window-demands-attention-focus = true;
      animation = 4;
      startup-status = 1;
    };
    "org/gnome/Ptyxis" = {
      font-name = "Hack 12";
      use-system-font = false;
    };
  };

  home.packages = with pkgs; [
    gnome-shell-extensions
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.displays-adjustments
    gnomeExtensions.hot-edge
    gnomeExtensions.appindicator
    gnomeExtensions.emoji-copy
    gnomeExtensions.just-perfection
    gnomeExtensions.app-name-indicator
    gnomeExtensions.middle-click-to-close-in-overview
    # gnomeExtensions.one-thing
    gnomeExtensions.unblank
    gnomeExtensions.clipboard-indicator
    ptyxis
    adwaita-icon-theme
    adwaita-icon-theme-legacy
    morewaita-icon-theme
    gnome-themes-extra
    libadwaita
    adwaita-qt
    adwaita-qt6
    ddcutil-service
    xdg-utils
  ];
}
