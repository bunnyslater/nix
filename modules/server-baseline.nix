{ config, lib, pkgs, ... }:
let
  cfg = config.workstation.server;
in
{
  options.workstation.server.enable = lib.mkEnableOption "Server baseline configuration";

  config = lib.mkIf cfg.enable {
    # Nix core settings
    nix = {
      settings.experimental-features = [ "nix-command" "flakes" ];
      gc = {
        automatic = true;
        dates = "weekly";
        options = "-d";
      };
      optimise.automatic = true;
    };

    nixpkgs.config.allowUnfree = true;

    # Bootloader — inherits module args, so per-machine overrides work
    boot.loader = {
      timeout = 1;
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
    };

    # SSH daemon
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    # Virtualisation
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          runAsRoot = true;
          swtpm.enable = true;
          verbatimConfig = ''
            cgroup_device_acl = [
              "/dev/null", "/dev/full", "/dev/zero",
              "/dev/random", "/dev/urandom",
              "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
              "/dev/rtc", "/dev/hpet",
            ];
          '';
        };
      };
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };

    # Samba — config ready but disabled
    services.samba = {
      enable = false;
      openFirewall = false;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "hermine";
          "netbios name" = "hermine";
          "security" = "user";
          "hosts allow" = "192.168.122. 192.168.8. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "Home Folder" = {
          "path" = "/home/bunny";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "bunny";
        };
      };
    };

    # User
    users.users.bunny = {
      isNormalUser = true;
      description = "bunny";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
      shell = pkgs.fish;
    };

    # Shell
    programs = {
      fish.enable = true;
      vim = {
        enable = true;
        defaultEditor = true;
      };
      mtr.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      _1password.enable = true;
    };

    # Security
    security.sudo.extraRules = [
      { users = [ "bunny" ];
        commands = [
          { command = "ALL" ;
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # Packages
    environment.systemPackages = with pkgs; [
      wget
      btop
      git
      gcc
      gnumake
      home-manager
      fastfetch
      wireguard-tools
      podman-compose
    ];

    # Console keymap
    console.keyMap = "uk";

    system.stateVersion = "25.11";
  };
}
