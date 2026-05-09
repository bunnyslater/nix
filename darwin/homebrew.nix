{ username, homebrew-core, homebrew-cask, homebrew-cmdx, ... }: {
  nix-homebrew = {
    # Install Homebrew under the default prefix (/opt/homebrew on Apple Silicon).
    enable = true;

    # Also install under the Intel prefix (/usr/local) so Rosetta 2 apps work.
    enableRosetta = false;

    # The macOS user that owns the Homebrew prefix.
    user = username;

    # Pin taps declaratively. Adding them here is the only way to use them;
    # `brew tap` is disabled when mutableTaps = false.
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "thedavidwenk/homebrew-cmdx" = homebrew-cmdx;
    };

    # Prevent imperative `brew tap` so the tap set stays fully reproducible.
    mutableTaps = false;
  };
}
