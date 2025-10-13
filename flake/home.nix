{ lib, pkgs, ... }: let
  username = "billie";
in {
  home = {
    inherit username;
    # This needs to actually be set to your username
    homeDirectory = "/home/" + username;

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "25.05";

    packages = with pkgs; [
      (pkgs.catppuccin-kde.override {
        flavour = ["mocha"];
        accents = ["lavender"];
      })
      pkgs.apple-color-emoji
      kdePackages.breeze-gtk
      vscode
    ];
  };

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
    autostart-signal-desktop = {
      Unit = {
        Description = "Start Signal Desktop at login";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe pkgs.signal-desktop;
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
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
  
  home.file.".local/share/silent-audio/silent-audio.sh" = {
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

  home.file.".local/share/silent-audio/silent.wav" = {
    source = ./silent-audio/silent.wav;
  };

  nix = {
    package = pkgs.nix;
    extraOptions = "experimental-features = nix-command flakes";
  };

  gtk = {
    enable = true;
    theme = {
      name = "breeze-gtk";
    };
  };

  home.file.".config/nixpkgs/config.nix" = {
    text = "{ allowUnfree = true; }";
  };

  xdg.desktopEntries.apple-notes = {
    name = "Apple Notes";
    exec = "${pkgs.ungoogled-chromium}/bin/chromium --app=https://icloud.com/notes";
    icon = "/home/${username}/.config/bunny/misc/apple-notes.ico"; 
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = {
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
      "text/plain" = [ "code.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/mailto" = [ "firefox.desktop" ];
    };
    defaultApplications = {
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
      "text/plain" = [ "code.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/mailto" = [ "firefox.desktop" ];
      "x-scheme-handler/x-github-client" = [ "github-desktop.desktop" ];
      "x-scheme-handler/x-github-desktop-auth" = [ "github-desktop.desktop" ];
      };
  };

  programs = {
    fish = {
      enable = true;
      shellAliases = {
        s = "sudo nixos-rebuild switch";
        hs = "cd ~/.config/bunny/flake && home-manager switch --flake .#${username}";
        tidyup = "nix-collect-garbage -d";
        fastfetch = "hyfetch";
        rmgtk = "rm ~/.gtkrc-2.0";
      };
      interactiveShellInit = ''
        set fish_greeting
      '';
    };

    firefox = {
      enable = true;
      policies = {
        DontCheckDefaultBrowser = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        NoDefaultBookMarks = true;
        PasswordManagerEnabled = false;
        ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          default_area = "menupanel";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
          };
        };
        FirefoxHome = {
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          Stories = false;
          SponsoredPocket = false;
          SponsoredStories = false;
        };
        Preferences = {
          "browser.uidensity" = {
            "Value" = 1;
            "Status" = "default";
            "Type" = "number";
          };
          "browser.aboutConfig.showWarning" = {
            "Value" = true;
            "Type" = "locked";
          };
        };
        UserMessaging.MoreFromMozilla = false;
        ReqestedLocales = "en-GB,fr";
      };
    };

    plasma = {
      enable = true;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        colorScheme = "CatppuccinMochaLavender";
        iconTheme = "breeze-dark";
        wallpaper = "/home/${username}/.config/bunny/misc/jamie-kettle-CziCVd8c9lU-unsplash\ copy\ 2.jpg";
      };
      panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        floating = false;
        opacity = "translucent";
        height = 28;
        widgets = [
          # We can configure the widgets by adding the name and config
          # attributes. For example to add the the kickoff widget and set the
          # icon to "nix-snowflake-white" use the below configuration. This will
          # add the "icon" key to the "General" group for the widget in
          # ~/.config/plasma-org.kde.plasma.desktop-appletsrc.
          {
            name = "org.kde.plasma.kickoff";
          }
          # Adding configuration to the widgets can also for example be used to
          # pin apps to the task-manager, which this example illustrates by
          # pinning dolphin and konsole to the task-manager by default with widget-specific options.
          # Or you can do it manually, for example:
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:firefox.desktop"
                  "applications:1password.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:systemsettings.desktop"
                  "applications:apple-notes.desktop"
                  "applications:signal.desktop"
                  "applications:chromium-browser.desktop"
                  "applications:anki.desktop"
                  "applications:code.desktop"
                ];
              };
            };
          }
          "org.kde.plasma.pager"
          # If no configuration is needed, specifying only the name of the
          # widget will add them with the default configuration.
          # "org.kde.plasma.marginsseparator"
          # If you need configuration for your widget, instead of specifying the
          # the keys and values directly using the config attribute as shown
          # above, plasma-manager also provides some higher-level interfaces for
          # configuring the widgets. See modules/widgets for supported widgets
          # and options for these widgets. The widgets below shows two examples
          # of usage, one where we add a digital clock, setting 12h time and
          # first day of the week to Sunday and another adding a systray with
          # some modifications in which entries to show.
          {
            systemTray.items = {
              # We explicitly show bluetooth and battery
              shown = [
                "org.kde.plasma.volume"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.brightness"
                "org.kde.plasma.battery"
              ];
              # And explicitly hide networkmanagement and volume
              hidden = [
                "org.kde.plasma.bluetooth"
              ];
            };
          }
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
    };
  };

  home.file.".local/share/konsole/Breeze.colorscheme" = {
    text = ''
      [Background]
      Color=20,29,42

      [BackgroundFaint]
      Color=49,54,59

      [BackgroundIntense]
      Color=0,0,0

      [Color0]
      Color=35,38,39

      [Color0Faint]
      Color=49,54,59

      [Color0Intense]
      Color=127,140,141

      [Color1]
      Color=237,21,21

      [Color1Faint]
      Color=120,50,40

      [Color1Intense]
      Color=192,57,43

      [Color2]
      Color=17,209,22

      [Color2Faint]
      Color=23,162,98

      [Color2Intense]
      Color=28,220,154

      [Color3]
      Color=246,116,0

      [Color3Faint]
      Color=182,86,25

      [Color3Intense]
      Color=253,188,75

      [Color4]
      Color=29,153,243

      [Color4Faint]
      Color=27,102,143

      [Color4Intense]
      Color=61,174,233

      [Color5]
      Color=155,89,182

      [Color5Faint]
      Color=97,74,115

      [Color5Intense]
      Color=142,68,173

      [Color6]
      Color=26,188,156

      [Color6Faint]
      Color=24,108,96

      [Color6Intense]
      Color=22,160,133

      [Color7]
      Color=252,252,252

      [Color7Faint]
      Color=99,104,109

      [Color7Intense]
      Color=255,255,255

      [Foreground]
      Color=252,252,252

      [ForegroundFaint]
      Color=239,240,241

      [ForegroundIntense]
      Color=61,174,233

      [General]
      Anchor=0.5,0.5
      Blur=false
      ColorRandomization=false
      Description=Breeze
      FillStyle=Tile
      Opacity=1
      Wallpaper=
      WallpaperFlipType=NoFlip
      WallpaperOpacity=1 '';
  };

  home.file.".local/share/konsole/Profile\ 1.profile" = {
    text = ''
      [Appearance]
      ColorScheme=Breeze
      Font=Hack,12,-1,7,400,0,0,0,0,0,0,0,0,0,0,1

      [General]
      Name=Profile 1
      Parent=FALLBACK/
    '';
  };

  home.file.".config/dolphinrc" = {
    text = ''
        MenuBar=Disabled

        [DetailsMode]
        IconSize=48
        RightPadding=23

        [ExtractDialog]
        1536x960 screen: Height=540
        1536x960 screen: Width=1024

        [FileDialogSize]
        2 screens: Height=584
        2 screens: Width=820

        [General]
        GlobalViewProps=false
        ShowFullPath=true
        ShowStatusBar=FullWidth
        Version=202
        ViewPropsTimestamp=2025,7,20,15,23,11.818

        [IconsMode]
        IconSize=80
        PreviewSize=144

        [KFileDialog Settings]
        Places Icons Auto-resize=false
        Places Icons Static Size=22

        [PreviewSettings]
        Plugins=appimagethumbnail,audiothumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,opendocumentthumbnail,svgthumbnail,gdk-pixbuf-thumbnailer

        [Search]
        Location=Everywhere

        [ViewPropertiesDialog]
        1536x960 screen: Height=714
        1536x960 screen: Width=379
    '';
  };
}