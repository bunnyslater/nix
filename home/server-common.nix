{ lib, config, pkgs, ... }: {
  home = {
    username = "bunny";
    homeDirectory = "/home/bunny";
    stateVersion = "25.11";
  };

  # Shell
  programs = {
    fish = {
      enable = true;
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
          echo -n " ($hostname)"
          set_color normal
        end
      '';
    };

    git = {
      enable = true;
      userName = "bunnyslater";
      userEmail = "211062560+bunnyslater@users.noreply.github.com";
    };

    hyfetch = {
      enable = true;
      settings = {
        preset = "transgender";
        mode = "rgb";
        light_dark = "dark";
        lightness = 0.65;
        color_align = {
          mode = "horizontal";
          custom_colors = [];
          fore_back = null;
        };
        backend = "fastfetch";
        args = null;
        distro = null;
        pride_month_shown = [];
        pride_month_disable = false;
      };
    };
  };

  # Remove GTK2 backup file on activation
  home.activation.removeGtkBackup = config.lib.dag.entryAfter ["writeBoundary"] ''
    rm -f "$HOME/.gtkrc-2.0.backup"
  '';
}
