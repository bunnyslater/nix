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
      users.${globals.username}.picture = ../misc/pfp.jpg;
    };
  };

  # Define users' settings and their packages.
  users.users.${globals.username} = {
    isNormalUser = true;
    description = globals.username;
    extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" ];
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
      htop
      gcc
      gnumake
      git
      home-manager
      fastfetch
      hyfetch
      vopono
      mullvad
      mullvad-vpn
      ungoogled-chromium
      power-profiles-daemon
      alsa-utils
      appleColorEmoji 
    ] ++ (lib.optional globals.enableVirtualization virt-manager);
    sessionVariables = {
      GTK_THEME = "Breeze";
    };
  };

  # Configure virtualisation, enable libvirt and podman.
  virtualisation = lib.mkIf globals.enableVirtualization {
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

  system.stateVersion = globals.stateVersion;

}
