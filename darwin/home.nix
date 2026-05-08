{ username, hostname, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    users.${username} = {
      home = {
        username = username;
        homeDirectory = "/Users/${username}";
        stateVersion = "25.11";
      };

      imports = [ ./iterm2.nix ];

      fonts.fontconfig.enable = true;

      programs.fish = {
        enable = true;


        loginShellInit = ''
          fish_add_path /run/current-system/sw/bin
          fish_add_path /nix/var/nix/profiles/default/bin
          fish_add_path /opt/homebrew/bin
          fish_add_path /Users/${username}/.local/bin
        '';
        shellAliases = {
          s = "sudo darwin-rebuild switch --flake ~/.config/bunny#${hostname}";
          fastfetch = "hyfetch";
          tidyup = "nix-collect-garbage -d";
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
    };
  };
}
