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
  layoutVariant = "mac";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/baseline.nix
    ../../modules/gnome.nix
    ../../modules/flatpak.nix
  ];

  workstation = {
    baseline.enable = true;
    gnome.enable = true;
  };

  # Hostname
  networking.hostName = "vm";

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
      enable = true;
      videoDrivers = [ "nvidia" ];
      # Define keymap in X11.
      xkb = lib.mkMerge [
        { layout = layout; }
        (lib.mkIf (layoutVariant != null) { variant = layoutVariant; })
      ];
    };
  };

  # Configure NVIDIA drivers.
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
    };
  };
}
