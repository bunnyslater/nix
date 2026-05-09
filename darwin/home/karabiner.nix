{ ... }:

{
  # Configure Karabiner-Elements
  xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
    profiles = [
      {
        complex_modifications = {
          rules = [
            {
              description = "⌘ + ⌥ + Return opens Paper Mess";
              manipulators = [
                {
                  from = {
                    key_code = "return_or_enter";
                    modifiers = { mandatory = [ "left_command" "left_option" ]; };
                  };
                  to = [{ shell_command = "open '/Applications/Paper Mess.app'"; }];
                  type = "basic";
                }
              ];
            }
            {
              description = "Caps Lock opens TinyStart, ⌥ + Caps Lock opens Spotlight";
              manipulators = [
                {
                  from = {
                    key_code = "caps_lock";
                    modifiers = {
                      mandatory = [ "left_alt" ];
                      optional = [ "any" ];
                    };
                  };
                  to = [{ apple_vendor_keyboard_key_code = "spotlight"; }];
                  type = "basic";
                }
                {
                  from = { key_code = "caps_lock"; };
                  to = [
                    {
                      key_code = "f16";
                      modifiers = [ "left_shift" ];
                    }
                  ];
                  type = "basic";
                }
              ];
            }
            {
              description = "⌃ + ⌥ + Q opens DeepL in Helium";
              manipulators = [
                {
                  from = {
                    key_code = "q";
                    modifiers = { mandatory = [ "left_control" "left_option" ]; };
                  };
                  to = [{ shell_command = "open /Applications/Helium.app -u 'https://www.deepl.com/fr/translator'"; }];
                  type = "basic";
                }
              ];
            }
            {
              description = "⌘ + ⌥ + T opens a new Terminal window";
              manipulators = [
                {
                  from = {
                    key_code = "t";
                    modifiers = { mandatory = [ "left_command" "left_option" ]; };
                  };
                  to = [{ shell_command = "open /Applications/iTerm.app"; }];
                  type = "basic";
                }
              ];
            }
          ];
        };
        fn_function_keys = [
          {
            from = { key_code = "f3"; };
            to = [{ apple_vendor_top_case_key_code = "illumination_down"; }];
          }
          {
            from = { key_code = "f4"; };
            to = [{ apple_vendor_top_case_key_code = "illumination_up"; }];
          }
          {
            from = { key_code = "f5"; };
            to = [{ key_code = "vk_none"; }];
          }
        ];
        name = "Default profile";
        selected = true;
        virtual_hid_keyboard = { keyboard_type_v2 = "iso"; };
      }
    ];
  };
}
