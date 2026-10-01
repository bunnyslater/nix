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
    ../../modules/plasma.nix
    ../../modules/flatpak.nix
  ];

  workstation = {
    baseline.enable = true;
    plasma.enable = true;
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
      # Define keymap in X11.
      xkb = lib.mkMerge [
        { layout = layout; }
        (lib.mkIf (layoutVariant != null) { variant = layoutVariant; })
      ];
    };
  };
}
