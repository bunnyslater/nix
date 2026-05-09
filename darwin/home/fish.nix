{ hostname, ... }:

{
  programs.fish = {
    enable = true;

    loginShellInit = ''
      fish_add_path /run/current-system/sw/bin
      fish_add_path /nix/var/nix/profiles/default/bin
      fish_add_path /opt/homebrew/bin
      fish_add_path ~/.local/bin

      export OPENCODE_API_KEY="op://Personal/Opencode API Key/credential"
      export EDITOR="zed"
    '';

    shellAliases = {
      s = "sudo darwin-rebuild switch --flake ~/dev/nix#${hostname}";
      fastfetch = "hyfetch";
      tidyup = "nix-collect-garbage -d";
      omp = "op run -- omp";
      pi = "op run -- omp";
    };

    interactiveShellInit = ''
      set fish_greeting
      function fish_prompt
        set_color cyan
        echo -n '⋊> '
        set_color FF8800
        echo -n (prompt_pwd)
        set_color normal
        echo -n ' '
      end

      function fish_right_prompt
        set_color brgrey
        date "+%H:%M:%S"
        set_color normal
      end
    '';
  };
}
