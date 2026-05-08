{ pkgs, username, ... }: {
  # https://daiderd.com/nix-darwin/manual/index.html#sec-options

  system = {
    stateVersion = 6;
    defaults = {
      menuExtraClock.Show24Hour = true;
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        tilesize = 52;
        show-recents = false;
        showhidden = true;
        mineffect = "scale";
        persistent-apps = [
          "/Applications/Helium.app"
          "/Applications/1Password.app"
          "/Applications/iTerm.app"
          "/System/Applications/Messages.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Notes.app"
          "/System/Applications/Reminders.app"
          "/Applications/Signal.app"
          "/Applications/Amperfy.app"
          "/System/Applications/iPhone Mirroring.app"
          "/Applications/Zed.app"
          "/System/Applications/System Settings.app"
        ];
        persistent-others = [
          { folder = { path = "/Applications"; showas = "grid"; displayas = "folder"; }; }
          { folder = { path = "/Users/${username}/Nextcloud/Screenshots"; showas = "grid"; displayas = "folder"; }; }
          { folder = { path = "/Users/${username}/Documents"; showas = "grid"; displayas = "folder"; }; }
          { folder = { path = "/Users/${username}/Downloads"; displayas = "folder"; }; }
        ];
      };
      finder = {
        NewWindowTarget = "Home";
        QuitMenuItem = true;
        FXPreferredViewStyle = "Nlsv";
        FXDefaultSearchScope = "SCcf";
        ShowStatusBar = true;
        ShowPathbar = true;
        AppleShowAllExtensions = true;
      };
    };
  };

  # TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Required for nix-darwin to manage the zsh environment.
  programs.zsh.enable = true;

  # Writes /etc/fish/ vendor config for the nix environment.
  programs.fish.enable = true;

  # /etc/shells must list the login shell path for chsh to accept it.
  # Uses the Homebrew fish since the nix-built fish binary is killed by
  # macOS in this VM environment.
  environment.shells = [ pkgs.zsh pkgs.bash "/opt/homebrew/bin/fish" ];

  # Set wallpaper using osascript/Finder
  launchd.user.agents.setWallpaper = {
    command = "/usr/bin/osascript -e 'tell application \"Finder\" to set desktop picture to POSIX file \"/Users/${username}/Pictures/Wallpapers/art002e009285~large.jpg\"'";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/setWallpaper.log";
      StandardErrorPath = "/tmp/setWallpaper.err";
    };
  };

  # Configure Finder sidebar (items not available in system.defaults.finder)
  system.activationScripts.configureFinderSidebar.text = ''
    # Hide recent tags
    /usr/bin/defaults write com.apple.finder ShowRecentTags -bool false

    # Clear favorite tags
    /usr/bin/defaults write com.apple.finder FavoriteTagNames -array

    # Hide Recents and Shared from sidebar (if keys exist)
    /usr/bin/defaults write com.apple.finder FXRecentFolders -array 2>/dev/null || true

    # Restart Finder to apply
    /usr/bin/killall Finder 2>/dev/null || true
  '';

  # Configure screenshots location
  system.activationScripts.configureScreenshots.text = ''
    /usr/bin/mkdir -p "/Users/${username}/Nextcloud/Screenshots"
    /usr/bin/defaults write com.apple.screencapture location -string "/Users/${username}/Nextcloud/Screenshots"
    /usr/bin/killall SystemUIServer 2>/dev/null || true
  '';

  # Configure mouse settings
  system.activationScripts.configureMouse.text = ''
    # Disable mouse acceleration (linear = 1 means no acceleration)
    /usr/bin/defaults write .GlobalPreferences com.apple.mouse.linear -bool true

    # Set mouse speed (scaling) to 0.875
    /usr/bin/defaults write .GlobalPreferences com.apple.mouse.scaling -float 0.875

    # Set click weight (FirstClickThreshold) to 2
    /usr/bin/defaults write .GlobalPreferences com.apple.mouse.firstClickThreshold -int 2

    # HID Mouse scroll settings
    /usr/bin/defaults write com.apple.driver.AppleHIDMouse ScrollH -int 1
    /usr/bin/defaults write com.apple.driver.AppleHIDMouse ScrollS -int 4
    /usr/bin/defaults write com.apple.driver.AppleHIDMouse ScrollSSize -int 30
    /usr/bin/defaults write com.apple.driver.AppleHIDMouse ScrollV -int 1
  '';

  # Disable Apple Intelligence
  system.activationScripts.disableAppleIntelligence.text = ''
    /usr/bin/defaults write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool false
  '';
}
