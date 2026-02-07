{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # Import apple-color-emoji.nix.
  appleColorEmoji = import ./apple-color-emoji.nix { inherit pkgs; };
  
  cfg = config.workstation.baseline;
in
{
  imports = [ ./profile-picture.nix ];

  options.workstation.baseline.enable = lib.mkEnableOption "Baseline workstation configuration";

  config = lib.mkIf cfg.enable {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    nixpkgs.config.allowUnfree = true;

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
    };

    hardware = {
      firmware = [ pkgs.sof-firmware ];
      bluetooth.enable = true;
      i2c.enable = true;
      enableAllFirmware = true;
    };

    networking.networkmanager.enable = true;

    services = {    
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
            "path" = "/home/billie";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
            "force user" = "billie";
          };
        };
      };
    };

    # Define users' settings and their packages.
    users.users.billie = {
      isNormalUser = true;
      description = "billie";
      extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "i2c" ];
      shell = pkgs.fish;
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

    # Configure fonts.
    fonts = {
      enableDefaultPackages = false;
      packages = with pkgs; [
        inter
        source-han-sans
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
        polkitPolicyOwners = [ "billie" ];
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
        virt-manager
        looking-glass-client
      ];
    };

    # Configure virtualisation, enable libvirt and podman.
    virtualisation = {
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

    # Create SHM file required by looking-glass
    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 billie libvirtd -"
    ];

    # Define console keymap.
    console.keyMap = "uk";

    system.stateVersion = "25.11";
  };
}
