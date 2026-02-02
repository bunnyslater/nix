{
  # Configure variables.

  username = "billie";
  hostname = "vm";

  locale = "fr_FR.UTF-8";
  timeZone = "Europe/London";
  
  # For a list of available XKB layouts, see:
  # localectl list-x11-keymap-layouts
  # For variants, see:
  # SYSTEMD_KEYMAP_DIRECTORIES=$(nix eval --raw 'nixpkgs#kbd')/share/keymaps localectl list-keymaps
  # This fucked up command courtesy of DivineGod on GitHub
  layout = "gb";
  layoutVariant = "mac";

  # For a list of available console keymaps, see:
  # https://git.kernel.org/pub/scm/linux/kernel/git/legion/kbd.git/tree/data/keymaps
  consoleKeyMap = "uk";

  enablePlasma = false;
  enableGnome = true;

  enableNvidiaDrivers = true;
  enableVirtualization = true;

  stateVersion = "25.11";

}