{ lib, pkgs, ... }: let
  username = "billie";
in {
  home = {
    inherit username;
    homeDirectory = "/home/" + username;
    stateVersion = "25.05";

    packages = with pkgs; [
      (pkgs.catppuccin-kde.override {
        flavour = ["mocha"];
        accents = ["lavender"];
      })
      kdePackages.breeze-gtk
      vscode
    ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Apple Color Emoji" ];
    };
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
        ExecStart = "${pkgs.flatpak}/bin/flatpak run org.signal.Signal";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    # silent-audio = {
    #   Unit = {
    #     Description = "Silent Audio to Prevent HDA Failure";
    #   };
    #   Service = {
    #     ExecStart = "%h/.local/share/silent-audio/silent-audio.sh";
    #     Restart = "on-failure";
    #     RestartSec = "10s";
    #     Environment = "XDG_RUNTIME_DIR=%t";
    #   };
    #   Install = {
    #     WantedBy = [ "default.target" ];
    #   };
    # };
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

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  home.file.".config/libvirt/qemu.conf" = {
    text = ''
      nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
    '';
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
      "text/plain" = [ "kate.desktop" ];
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
      "text/plain" = [ "kate.desktop" ];
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
        hs = "rm ~/.gtkrc-2.0 && cd ~/.config/bunny/flake && home-manager switch --flake .#${username}";
        tidyup = "nix-collect-garbage -d";
        fastfetch = "hyfetch";
      };
      interactiveShellInit = ''
        set fish_greeting
        function fish_prompt
          set_color cyan
          echo -n '⋊> '
          set_color FF8800
          echo -n (prompt_pwd)
          set_color normal
          echo -n ' '
        end

        function fish_right_prompt
          set_color brgrey
          date "+%H:%M:%S"
          set_color normal
        end
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
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
          };
          "{61a05c39-ad45-4086-946f-32adb0a40a9d}" = {
            default_area = "menupanel";
            install_url = "http://addons.mozilla.org/firefox/downloads/latest/linkding-extension/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
          };
          "{4908d5d9-b33e-4cae-9cfe-9d7093ae4d9b}" = {
            default_area = "menupanel";
            install_url = "http://addons.mozilla.org/firefox/downloads/latest/open-temp-container/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
          };
          "uBlock0@raymondhill.net" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "gdpr@cavi.au.dk" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "jid1-BoFifL9Vbdl2zQ@jetpack" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "addon@darkreader.org" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
          };
          "{531906d3-e22f-4a6c-a102-8057b88a1a63}" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/single-file/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
          };
          "openmultipleurls@ustat.de" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/open-multiple-tab-urls/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "{17165bd9-9b71-4323-99a5-3d4ce49f3d75}" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/export-tabs-urls-and-titles/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "sponsorBlocker@ajay.app" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
          };
          "{5cce4ab5-3d47-41b9-af5e-8203eea05245}" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/control-panel-for-twitter/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
          };
          "{6b733b82-9261-47ee-a595-2dda294a4d08}" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/yomitan/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
          };
          "treestyletab@piro.sakura.ne.jp" = {
            default_area = "menupanel";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tree-style-tab/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = false;
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

    hyfetch = {
      enable = true;
      settings = {
        preset = "transgender";
        mode = "rgb";
        light_dark = "dark";
        lightness = 0.65;
        color_align = {
            mode = "horizontal";
            custom_colors = [];
            fore_back = null;
        };
        backend = "fastfetch";
        args = null;
        distro = null;
        pride_month_shown = [];
        pride_month_disable = false;
      };
    };

    # distrobox = {
    #   enable = true;
    #   containers = {
    #     arch = {
    #       additional_packages = "git base-devel fakeroot fastfetch hyfetch noto-fonts signal-desktop";
    #       entry = true;
    #       image = "docker.io/library/archlinux:latest";
    #       exported_apps = [
    #         "/usr/share/applications/signal-desktop.desktop"
    #       ];
    #     };
    #   };
    # };

    plasma = {
      enable = true;
      workspace = {
        lookAndFeel = "org.kde.breezedark.desktop";
        colorScheme = "CatppuccinMochaLavender";
        iconTheme = "breeze-dark";
        wallpaper = "/home/${username}/.config/bunny/misc/jamie-kettle-CziCVd8c9lU-unsplash\ copy\ 2.jpg";
      };
      kscreenlocker.appearance.wallpaper = "/home/${username}/.config/bunny/misc/jamie-kettle-CziCVd8c9lU-unsplash\ copy\ 2.jpg";
      panels = [
      {
        location = "bottom";
        floating = false;
        # opacity = "translucent";
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
                  "applications:org.signal.Signal.desktop"
                  "applications:virt-manager.desktop"
                  "applications:chromium-browser.desktop"
                  "applications:anki.desktop"
                  "applications:code.desktop"
                ];
              };
            };
          }
          "org.kde.plasma.pager"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.volume"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.brightness"
                "org.kde.plasma.battery"
              ];
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
