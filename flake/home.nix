{ lib, pkgs, ... }: let
  # Import global variables
  globals = import ../nixos/globals.nix;
  username = globals.username;
in {
  imports = [
    # Plasma-manager configuration (configures wallpaper, theme, etc.) and a couple abitrary files (Konsole colorscheme and profile, .dolphinrc).
    ./plasma.nix
    # Firefox configuration. Extensions and preferences.
    ./firefox.nix
    # XDG configuration. XDG, among other things, is the standard .desktop files work with, and sets up file associations.
    ./xdg.nix
    # silent-audio fixes audio issues on Yoga Pro 9 14IRP8/16IRP8 devices by creating a systemd service that loops a silent audio file.
    # Unless you are using one of these devices, comment this out.
    # ./silent-audio.nix
  ];

  home = {
    username = globals.username;
    homeDirectory = "/home/" + username;
    stateVersion = globals.stateVersion;

    # Defines installed user packages
    packages = with pkgs; [
      (pkgs.catppuccin-kde.override {
        flavour = ["mocha"];
        accents = ["lavender"];
      })
      kdePackages.kate
      kdePackages.filelight
      eog
      _1password-gui
      vlc
      nextcloud-client
      libreoffice-qt6-fresh
      transmission_4-qt6
      remmina
      anki-bin
      vscode
      tor-browser
    ];

    # Some programs cannot be managed by home-manager directly, so for them we define abitrary files for them here.
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

  # Enables and configures user programs.
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

  # Configures systemd user services.
  ## autostart-* runs programs at login.
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
  };

  # Configures Apple Color Emoji to be the default emoji font.
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Apple Color Emoji" ];
    };
  };

  # Required for flake usage.
  nix = {
    package = pkgs.nix;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # Configures Breeze to be the default GTK theme.
  gtk = {
    enable = true;
    theme = {
      name = "breeze-gtk";
    };
  };

  # virt-manager uses dconf for some settings storage. This tells virt-manager to make qemu://system avaliable in GUI.
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
