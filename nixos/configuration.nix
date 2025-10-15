{ config, pkgs, lib, ... }:

let
  nvidia = true;
  appleColorEmoji = import ../flake/assets/apple-color-emoji.nix { inherit pkgs; };
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../flake/assets/profile-picture.nix
    ];

  # Configure NVIDIA drivers.
  hardware = {
    graphics = lib.mkIf nvidia {
      enable = true;
      enable32Bit = true;
    };
    nvidia = lib.mkIf nvidia {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };
  };
  
  # Configure bootloader and modprobe.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig = ''
      options snd_hda_intel power_save=0
      options kvm_intel nested=1
    '';
  };

  # Configure networking.
  networking = {
    # Define hostname.
    hostName = "nixos";
    # Enable NetworkManager.
    networkmanager.enable = true;
  };
  
  # Define time zone.
  time.timeZone = "Europe/London";

  # Define locales.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  # Define and configure services including desktop environment, audio, etc.
  services = {
    xserver = {
      enable = true;
      videoDrivers = lib.mkIf nvidia [ "nvidia" ];
      # Define keymap in X11.
      xkb = {
        layout = "gb";
        variant = "mac";
      };
    };
    # Enable the KDE Plasma Desktop Environment.
    displayManager = {
      sddm.enable = true;
      sddm.wayland.enable = true;
      defaultSession = "plasma";
    };
    desktopManager.plasma6.enable = true;
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
      users.billie.picture = ../misc/pfp.jpg;
    };
  };

  # Define users' settings and their packages.
  users.users.billie = {
    isNormalUser = true;
    description = "billie";
    extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.filelight
      ungoogled-chromium
      _1password-gui
      anki-bin
      nextcloud-client
      vlc
      libreoffice-qt6-fresh
      remmina
      tor-browser
      transmission_4-qt6
      eog
    ];
  };

  # Configure security. 
  # rtkit enables real-time scheduling for user-space applications, important for pipewire.
  # Enable passwordless sudo for myself because that's what I prefer.
  security = {
    rtkit.enable = true;
    sudo.extraRules = [
      { users = [ "billie" ];
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
  };

  # Define system-wide packages and set default GTK theme to Breeze for them.
  environment = {
    systemPackages = with pkgs; [
      wget
      fastfetch
      hyfetch
      vopono
      htop
      mullvad
      mullvad-vpn
      home-manager
      power-profiles-daemon
      gcc
      gnumake
      git
      alsa-utils
      appleColorEmoji
      virt-manager
    ];
    sessionVariables = {
      GTK_THEME = "Breeze";
    };
  };

  # Configure virtualisation, enable libvirt and podman.
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
        swtpm.enable = true;
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
      dejavu_fonts
      freefont_ttf
      gyre-fonts
      liberation_ttf
      unifont
      appleColorEmoji
    ];
  };

  # Define console keymap.
  console.keyMap = "uk";

  # Allow unfree packages on a system level e.g. vscode, NVIDIA drivers, etc.
  nixpkgs.config.allowUnfree = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05";

}
