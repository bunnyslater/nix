{ config, pkgs, lib, ... }:

let
  # Import global variables.
  globals = import ./globals.nix;
  
  # Import apple-color-emoji.nix.
  appleColorEmoji = import ../flake/assets/apple-color-emoji.nix { inherit pkgs; };
in
{
  imports =
    [
      ../flake/assets/profile-picture.nix
      # ./yoga-audio.nix fixes audio on Yoga Pro 9 Gen 3 devices. Remove if unneeded. 
      ./yoga-audio.nix
    ];

  # Configure NVIDIA drivers.
  hardware = {
    graphics = lib.mkIf globals.enableNvidiaDrivers {
      enable = true;
      enable32Bit = true;
    };
    nvidia = lib.mkIf globals.enableNvidiaDrivers {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };
    firmware = [ pkgs.sof-firmware ];
    bluetooth.enable = true;
    i2c.enable = true;
  };
  
  # Configure bootloader and modprobe.
  boot = {
    loader = {
      timeout = 1;
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      }; 
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "i2c-dev" ];
    extraModprobeConfig = ''
      options kvm_intel nested=1
      # Stubs out my RTX 4060 Mobile for use in virtual machines. You should absolutely remove this.
      options vfio-pci ids=10de:28e0,10de:22be
      # The below fixes audio on Yoga Pro 9 Gen 3 devices. You should probably also remove this. 
      options snd_hda_intel power_save=0 probe_mask=1
      options snd_sof_intel_hda_common hda_model=alc287-yoga9-14irp8
    '';
  };

  # Configure networking.
  networking = {
    # Define hostname.
    hostName = globals.hostname;
    # Enable NetworkManager.
    networkmanager.enable = true;
  };
  
  # Define time zone.
  time.timeZone = globals.timeZone;

  # Define locales.
  i18n = {
    defaultLocale = "${globals.locale}";
    extraLocaleSettings = {
      LC_CTYPE = "${globals.locale}";
      LC_COLLATE = "${globals.locale}";
      LC_MESSAGES = "${globals.locale}";
      LC_ADDRESS = "${globals.locale}";
      LC_IDENTIFICATION = "${globals.locale}";
      LC_MEASUREMENT = "${globals.locale}";
      LC_MONETARY = "${globals.locale}";
      LC_NAME = "${globals.locale}";
      LC_NUMERIC = "${globals.locale}";
      LC_PAPER = "${globals.locale}";
      LC_TELEPHONE = "${globals.locale}";
      LC_TIME = "${globals.locale}";
    };
  };

  # Define and configure services including desktop environment, audio, etc.
  services = {
    xserver = {
      enable = true;
      videoDrivers = lib.mkIf globals.enableNvidiaDrivers [ "nvidia" ];
      # Define keymap in X11.
      xkb = lib.mkMerge [
        { layout = globals.layout; }
        (lib.mkIf (globals ? layoutVariant) { variant = globals.layoutVariant; })
      ];
    };
    # Enable the KDE Plasma or GNOME Desktop Environment based on configuration.
    displayManager = lib.mkMerge [
      (lib.mkIf globals.enablePlasma {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        defaultSession = "plasma";
      })
      (lib.mkIf globals.enableGnome {
        gdm = {
          enable = true;
        };
        defaultSession = "gnome";
      })
    ];
    desktopManager = lib.mkMerge [
      (lib.mkIf globals.enablePlasma {
        plasma6 = { enable = true; };
      })
      (lib.mkIf globals.enableGnome {
        gnome = { 
          enable = true;
          extraGSettingsOverrides = ''
          [org.gnome.mutter]
          experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
          '';
        };
      })
    ];
    # Enable CUPS to print documents.
    printing.enable = true;
    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    # Enable Flatpak support.
    flatpak.enable = true;
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };
    # Define user profile pictures.
    userProfilePicture = {
      enable = true;
      users.${globals.username}.picture = ../misc/pfp.jpg;
    };
    # Define evdev configuration. evdev can be used to remap keys and passthrough input devices to VMs.
    persistent-evdev = {
      enable = true;
      devices = {
        keyboard-main = "usb-Keychron_Keychron_K2_Pro-event-kbd";
        keyboard-if02 = "usb-Keychron_Keychron_K2_Pro-if02-event-kbd";
        mouse-keychron = "usb-Keychron_Keychron_K2_Pro-if02-event-mouse";
        mouse-logitech = "usb-Logitech_USB_Receiver-if02-event-mouse";
      };
    };
    samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "192.168.122. 192.168.8. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "Home Folder" = {
          "path" = "/home/${globals.username}";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "${globals.username}";
        };
      };
    };
  };

  # Define users' settings and their packages.
  users.users.${globals.username} = {
    isNormalUser = true;
    description = globals.username;
    extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "i2c" ];
    shell = pkgs.fish;
  };

  # Configure security. 
  # rtkit enables real-time scheduling for user-space applications, important for pipewire.
  # Enable passwordless sudo for myself because that's what I prefer.
  security = {
    rtkit.enable = true;
    sudo.extraRules = [
      { users = [ globals.username ];
        commands = [
          { command = "ALL" ;
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # Define and configure important system-level applications like default shell and editor.
  programs = {
    fish.enable = true;
    firefox.enable = false;
    vim = {
      enable = true;
      defaultEditor = true;
    };
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "${globals.username}" ];
    };
  };

  # Define system-wide packages and set default GTK theme to Breeze for them.
  environment = {
    systemPackages = with pkgs; [
      wget
      btop
      gcc
      gnumake
      git
      home-manager
      fastfetch
      hyfetch
      wireguard-tools
      vopono
      mullvad
      mullvad-vpn
      ungoogled-chromium
      mpv
      power-profiles-daemon
      alsa-utils
      appleColorEmoji
      gnome-tweaks
      i2c-tools
    ] ++ (lib.optionals globals.enableVirtualization [ virt-manager looking-glass-client ]);
      sessionVariables = lib.mkMerge [
        (lib.mkIf globals.enablePlasma {
          GTK_THEME = "Breeze";
        })
        (lib.mkIf globals.enableGnome {
          NIXOS_OZONE_WL = "1";
        })
      ];
  };

  # Configure virtualisation, enable libvirt and podman.
  virtualisation = lib.mkIf globals.enableVirtualization {
    libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
        swtpm.enable = true;
        verbatimConfig = ''
          # Allow access to necessary devices
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
            "/dev/rtc", "/dev/hpet",
            "/dev/input/by-id/uinput-keyboard-main",
            "/dev/input/by-id/uinput-keyboard-if02",
            "/dev/input/by-id/uinput-mouse-keychron",
            "/dev/input/by-id/uinput-mouse-logitech",
          ];
        '';
      };
    };
    spiceUSBRedirection.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  # Configure fonts.
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      inter
      dejavu_fonts
      freefont_ttf
      gyre-fonts
      liberation_ttf
      unifont
      appleColorEmoji
      hack-font
      adwaita-fonts
    ];
  };

  environment.gnome = lib.mkIf globals.enableGnome {
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

  # Create SHM file required by looking-glass
  systemd.tmpfiles.rules = lib.mkIf globals.enableVirtualization [
    "f /dev/shm/looking-glass 0660 ${globals.username} libvirtd -"
  ];

  # Define console keymap.
  console.keyMap = "uk";

  # Allow unfree packages on a system level e.g. vscode, NVIDIA drivers, etc.
  nixpkgs.config.allowUnfree = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = globals.stateVersion;

}
