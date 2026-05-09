{ pkgs, config, ... }: {
  # Packages available system-wide; reproducible and rollbackable.
  environment.systemPackages = with pkgs; [
    git
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # cleanup = "zap"; # uninstall anything not listed here
    };

    # Keep homebrew.taps aligned with the taps declared in nix-homebrew
    # so nix-darwin and nix-homebrew agree on what's present.
    taps = builtins.attrNames config.nix-homebrew.taps;

    # `brew install`
    brews = [ "defaultbrowser" "fastfetch" "fish" "hyfetch" "mas" "mpv" "ffmpeg" "imagemagick" ];

    # `brew install --cask`
    casks = [ "font-jetbrains-mono" "iterm2" "anki" "cardinal-search" "thedavidwenk/cmdx/cmdx" "dockdoor" "swift-shift" "grandperspective" "helium-browser" "hiddenbar" "jan" "karabiner-elements" "keyboardcleantool" "libreoffice" "middleclick" "moonlight" "mullvad-vpn" "musicbrainz-picard" "neohtop" "nextcloud" "pearcleaner" "prismlauncher" "rectangle" "scroll-reverser" "signal" "stats" "textmate" "transmission" "trex" "utm" "vlc" "zed" ];

    # Mac App Store apps
    # masApps = {
    #   "amperfy" = 1530145038;
    #   "amphetamine" = 937984704;
    #   "wireguard" = 1451685025;
    #   "paper-mess-ephemeral-notes" = 6754223651;
    # };
  };
}
