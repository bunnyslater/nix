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
        tilesize = 54;
        show-recents = false;
        showhidden = true;
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
          "/Applications"
          "/Users/${username}/Nextcloud/Screenshots"
          "/Users/${username}/Documents"
          "/Users/${username}/Downloads"
        ];
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
}
