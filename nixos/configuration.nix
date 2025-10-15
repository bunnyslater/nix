# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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

  services.userProfilePicture = {
    enable = true;
    users.billie.picture = ../misc/pfp.jpg;
  };

  hardware.graphics = lib.mkIf nvidia {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = lib.mkIf nvidia [ "nvidia" ];

  hardware.nvidia = lib.mkIf nvidia {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };

  # Bootloader.

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

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "mac";
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  security.sudo.extraRules= [
  { users = [ "billie" ];
    commands = [
       { command = "ALL" ;
         options= [ "NOPASSWD" ];
      }
    ];
  }
  ];

  services.flatpak.enable = true;

  fonts.enableDefaultPackages = false;
  fonts.packages = with pkgs; [
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    liberation_ttf
    unifont
    appleColorEmoji
  ];
  

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

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
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

  environment.sessionVariables = {
    GTK_THEME = "Breeze";
  };

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

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05";

}
