{ lib, pkgs, plasma-manager, config, ... }:
{
  imports = [
    # Plasma-manager configuration (configures wallpaper, theme, etc.) and a couple abitrary files (Konsole colorscheme and profile, .dolphinrc).
    # plasma-manager.homeModules.plasma-manager
    # ./plasma.nix
    # Firefox configuration. Extensions and preferences.
    ./firefox.nix
    # XDG configuration. XDG, among other things, is the standard .desktop files work with, and sets up file associations.
    ./xdg.nix
    # Gnome configuration. Cursor theme, Adwaita theme, etc.
    # ./gnome.nix
    # silent-audio fixes audio issues on Yoga Pro 9 14IRP8/16IRP8 devices by creating a systemd service that loops a silent audio file.
    # Unless you are using one of these devices, comment this out.
    # ../assets/silent-audio/silent-audio.nix
  ];

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Required for flake usage.
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  home = {
    username = "billie";
    homeDirectory = "/home/" + "billie";
    stateVersion = "25.11";

    # Defines installed user packages
    packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.kate
      kdePackages.filelight
      loupe
      vlc
      nextcloud-client
      libreoffice-qt6-fresh
      hunspell
      hunspellDicts.en_GB-ize
      hunspellDicts.fr-any
      transmission_4-qt6
      remmina
      anki-bin
      vscode
      nicotine-plus
      picard
      opencode
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
        # s = "sudo nixos-rebuild switch --flake ~/.config/bunny/flake#${globals.hostname}";
        # hs = "home-manager switch --flake ~/.config/bunny/flake#${username}";
        # update = "cd ~/.config/bunny/flake && nix flake update && sudo nixos-rebuild switch --flake .#${globals.hostname}";
        tidyup = "nix-collect-garbage -d";
        fastfetch = "hyfetch";
        vexec = "vopono exec --protocol wireguard --custom .no-osl-wg-004.conf";
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
    git = {
      enable = true;
      settings = {
        user = {
          name  = "bunnyslater";
          email = "211062560+bunnyslater@users.noreply.github.com";
        };
        init.defaultBranch = "main";
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

  # Configures Apple Color Emoji to be the default emoji font.
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      emoji = [ "Apple Color Emoji" ];
    };
  };

  # virt-manager uses dconf for some settings storage. This tells virt-manager to make qemu://system avaliable in GUI.
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  # Remove GTK2 backup file on activation
  home.activation.removeGtkBackup = config.lib.dag.entryAfter ["writeBoundary"] ''
    # Remove stale GTK2 backup if present
    rm -f "$HOME/.gtkrc-2.0.backup"
  '';
}
