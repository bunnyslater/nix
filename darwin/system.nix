{ pkgs, username, ... }: {
  # https://daiderd.com/nix-darwin/manual/index.html#sec-options

  system = {
    stateVersion = 6;

    defaults = {
      menuExtraClock.Show24Hour = true;
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
