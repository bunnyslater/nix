{ lib, pkgs, ... }: let
  # Import global variables
  globals = import ../nixos/globals.nix;
  username = globals.username;
in {
  imports = [
    # Plasma-manager configuration (configures wallpaper, theme, etc.) and a couple abitrary files (Konsole colorscheme and profile, .dolphinrc).
    ./plasma.nix
    # XDG configuration. XDG, among other things, is the standard .desktop files work with, and sets up file associations.
    ./xdg.nix
  ];

  home = {
    username = globals.username;
    homeDirectory = "/home/" + username;
    stateVersion = globals.stateVersion;

    # TODO: Move configuration.nix user packages here.
    packages = with pkgs; [
      (pkgs.catppuccin-kde.override {
        flavour = ["mocha"];
        accents = ["lavender"];
      })
      kdePackages.breeze-gtk
      vscode
    ];

    # Some programs cannot be managed by home-manager directly, so for them we define abitrary files here.
    file = {
      ".config/nixpkgs/config.nix" = {
        text = "{ allowUnfree = true; }";
      };
      ".config/libvirt/qemu.conf" = {
        text = ''
          nvram = [ "/run/libvirt/nix-ovmf/AAVMF_CODE.fd:/run/libvirt/nix-ovmf/AAVMF_VARS.fd", "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
        '';
      };
    };
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
        ExecStart = "${lib.getExe pkgs.flatpak} run --user org.signal.Signal";
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

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  programs = {
    fish = {
      enable = true;
      shellAliases = {
        s = "sudo nixos-rebuild switch";
        hs = "rm ~/.gtkrc-2.0 && cd ~/.config/bunny/flake && home-manager switch --flake .#${username}";
        update = "sudo nix-channel --update && sudo nixos-rebuild switch && cd ~/.config/bunny/flake && nix flake update && home-manager switch --flake .#${username}";
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
  };
}
