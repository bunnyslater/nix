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
    brews = [];

    # `brew install --cask`
    casks = [];
  };
}
