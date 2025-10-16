{ lib, globals, username, pkgs, ... }: let
  username = globals.username;

  # Define associations in a variable to avoid duplication
  associations = {
    "application/pdf" = [ "chromium-browser.desktop" ];
    "audio/aac" = [ "vlc.desktop" ];
    "audio/mp4" = [ "vlc.desktop" ];
    "audio/mpeg" = [ "vlc.desktop" ];
    "audio/mpegurl" = [ "vlc.desktop" ];
    "audio/ogg" = [ "vlc.desktop" ];
    "audio/vnd.rn-realaudio" = [ "vlc.desktop" ];
    "audio/vorbis" = [ "vlc.desktop" ];
    "audio/x-flac" = [ "vlc.desktop" ];
    "audio/x-mp3" = [ "vlc.desktop" ];
    "audio/x-mpegurl" = [ "vlc.desktop" ];
    "audio/x-ms-wma" = [ "vlc.desktop" ];
    "audio/x-musepack" = [ "vlc.desktop" ];
    "audio/x-oggflac" = [ "vlc.desktop" ];
    "audio/x-pn-realaudio" = [ "vlc.desktop" ];
    "audio/x-scpls" = [ "vlc.desktop" ];
    "audio/x-speex" = [ "vlc.desktop" ];
    "audio/x-vorbis" = [ "vlc.desktop" ];
    "audio/x-vorbis+ogg" = [ "vlc.desktop" ];
    "audio/x-wav" = [ "vlc.desktop" ];
    "image/bmp" = [ "org.gnome.eog.desktop" ];
    "image/jpeg" = [ "org.gnome.eog.desktop" ];
    "image/png" = [ "org.gnome.eog.desktop" ];
    "image/webp" = [ "org.gnome.eog.desktop" ];
    "image/x-icns" = [ "org.gnome.eog.desktop" ];
    "text/plain" = [ "kate.desktop" ];
    "video/mp4" = [ "vlc.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/mailto" = [ "firefox.desktop" ];
  };
in {
  xdg = {
  desktopEntries = {
    apple-notes = {
      name = "Apple Notes";
      exec = "${pkgs.ungoogled-chromium}/bin/chromium --app=https://icloud.com/notes";
      icon = "/home/${username}/.config/bunny/misc/apple-notes.ico"; 
    };
  }; 
  mimeApps = {
    enable = true;
    # Reuse the `associations` variable for both.
    associations.added = associations;
    defaultApplications = associations;
  };
  };
}