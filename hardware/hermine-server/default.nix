{ config, lib, pkgs, modulesPath, ... }:
let
  locale = "en_GB.UTF-8";
  timeZone = "Europe/London";
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGdRoHfx+feDtQCkjwIKr9uC5+6TILAcHamuvjjb4/o";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/server-baseline.nix
    ./gpu-passthrough.nix
  ];

  workstation.server.enable = true;

  # Hostname
  networking.hostName = "hermine";
  networking.hostId = "821cc3b0";

  # Networking — bridge + static IP
  networking.usePredictableInterfaceNames = false;
  networking.bridges.br0.interfaces = [ "eth0" ];
  networking.interfaces.br0.ipv4.addresses = [{
    address = "192.168.8.128";
    prefixLength = 24;
  }];
  networking.defaultGateway = "192.168.8.1";
  networking.nameservers = [ "192.168.8.1" "1.1.1.1" "8.8.8.8" ];
  networking.networkmanager.enable = false;

  # Time & locale
  time.timeZone = timeZone;
  i18n = {
    defaultLocale = locale;
    extraLocaleSettings = {
      LC_CTYPE = locale;
      LC_COLLATE = locale;
      LC_MESSAGES = locale;
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
    };
  };

  # GPU — nvidia driver active by default
  hardware.graphics.enable = true;
  hardware.nvidia.open = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Ollama with CUDA
  services.ollama = {
    enable = false;
    acceleration = "cuda";
  };

  # User SSH key
  users.users.bunny.openssh.authorizedKeys.keys = [ sshKey ];

  # Wireguard (TODO)
  # networking.wg-quick.interfaces.wg0.configFile = "/home/bunny/.home.conf";

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = true;
  boot.zfs.requestEncryptionCredentials = true;

  # RTL8153 USB Ethernet adapter
  boot.initrd.availableKernelModules = [ "r8152" ];

  # LUKS encrypted swap — open in initrd so systemd doesn't hang on /dev/mapper/cryptswap
  boot.initrd.luks.devices."cryptswap" = {
    device = "/dev/disk/by-uuid/467ea8c7-5bc0-485c-ba2c-a926c8dbdf45";
  };

  # Initrd — remote unlock via Tailscale + SSH
  # Bridge must be configured in initrd too (networking.bridges only applies to stage 2)
  boot.initrd = {
    systemd.enable = true;
    network = {
      enable = true;
      ssh.enable = true;
      ssh.authorizedKeys = [ sshKey ];
      ssh.hostKeys = [ /home/bunny/.secrets/initrd-ssh-key ];
    };
    systemd.network = {
      netdevs."br0" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br0";
        };
        bridgeConfig = {
          STP = false;
          ForwardDelaySec = 0;
        };
      };
      networks = {
        "05-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig.Bridge = "br0";
        };
        "05-br0" = {
          matchConfig.Name = "br0";
          addresses = [{
            addressConfig.Address = "192.168.8.128/24";
          }];
          routes = [{
            routeConfig.Gateway = "192.168.8.1";
          }];
          networkConfig = {
            DNS = [ "192.168.8.1" "1.1.1.1" "8.8.8.8" ];
            DHCP = "no";
            ConfigureWithoutCarrier = true;
          };
        };
      };
    };
    # Initrd SSH — wait for network before starting
    systemd.services."initrd-ssh" = {
      after = [ "systemd-networkd-wait-online.service" ];
      wants = [ "systemd-networkd-wait-online.service" ];
    };

    # Tailscale in initrd for remote unlock over the internet
    # Requires a Tailscale pre-auth key — generate at https://login.tailscale.com/admin/settings/authkeys
    # and store in /persist/secrets/tailscale-initrd-authkey
    systemd.services.tailscaled = {
      description = "Tailscale daemon (initrd)";
      wantedBy = [ "initrd.target" ];
      after = [ "systemd-networkd.service" "systemd-networkd-wait-online.service" ];
      requires = [ "systemd-networkd.service" ];
      wants = [ "systemd-networkd-wait-online.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state";
        ExecStartPost = "${pkgs.bash}/bin/bash -c '${pkgs.tailscale}/bin/tailscale up --auth-key=\"$(cat /tmp/tailscale-authkey)\"'";
      };
    };
  };

  # Inject Tailscale auth key into initrd
  boot.initrd.secrets."/tmp/tailscale-authkey" = /home/bunny/.secrets/tailscale-initrd-authKey;
}
