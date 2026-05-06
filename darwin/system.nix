{ ... }: {
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
}
