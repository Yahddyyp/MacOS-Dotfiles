{ pkgs, username, ... }:
{
  # disable caps lock so karabiner can intercept it
  launchd.agents.capslock-disable = {
    command = ''
      /usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0}]}' > /dev/null 2>&1
    '';
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = false;
    serviceConfig.StandardOutPath = "/tmp/capslock-disable.log";
    serviceConfig.StandardErrorPath = "/tmp/capslock-disable.err.log";
  };

  home-manager.users.${username} = {
    xdg.configFile."karabiner/karabiner.json".text = builtins.toJSON {
      profiles = [
        {
          name = "Default profile";
          selected = true;
          virtual_hid_keyboard = {
            keyboard_type_v2 = "ansi";
          };
          complex_modifications = {
            rules = [
              {
                description = "Caps Lock to Hyper (ctrl+alt+shift+cmd) on hold, Escape on tap";
                manipulators = [
                  {
                    type = "basic";
                    from = {
                      key_code = "caps_lock";
                      modifiers = {
                        optional = [ "any" ];
                      };
                    };
                    to = [
                      {
                        key_code = "left_control";
                        modifiers = [
                          "left_option"
                          "left_shift"
                          "left_command"
                        ];
                        lazy = true;
                      }
                    ];
                    to_if_alone = [
                      {
                        key_code = "escape";
                      }
                    ];
                    parameters = {
                      "basic.to_if_alone_timeout_milliseconds" = 400;
                      "basic.to_if_held_down_threshold_milliseconds" = 400;
                    };
                  }
                ];
              }
            ];
          };
        }
      ];
    };
  };
}
