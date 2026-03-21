{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  locale = "fr_FR.UTF-8";
  timeZone = "Europe/London";

  layout = "gb";
  layoutVariant = "uk";
in
{
  imports = [
    ./hardware-configuration.nix
    ./yoga-audio.nix
    ../../modules/baseline.nix
    ../../modules/gnome.nix
    ../../modules/flatpak.nix
  ];

  workstation = {
    baseline.enable = true;
    gnome.enable = true;
  };

  # Hostname
  networking.hostName = "hermine";

  # Wireguard (TODO: make declaritive)
  # networking.wg-quick.interfaces.wg0.configFile = "/home/billie/.home.conf";

  # Define time zone.
  time.timeZone = timeZone;

  # Define locales.
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

  # Define and configure services including desktop environment, audio, etc.
  services = {
    xserver = {
      # Define keymap in X11.
      xkb = lib.mkMerge [
        { layout = layout; }
        (lib.mkIf (layoutVariant != null) { variant = layoutVariant; })
      ];
    };
  };

  # Configure VFIO and modprobe.
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



}