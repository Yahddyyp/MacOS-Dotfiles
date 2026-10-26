{ pkgs, ... }:
{
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;

    config = {
      layout = "bsp";
      window_placement = "second_child";

      top_padding = 8;
      bottom_padding = 8;
      left_padding = 8;
      right_padding = 8;
      window_gap = 8;

      focus_follows_mouse = "autoraise";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_follows_focus = "on";

      # window opacity
      # window_opacity = "on";
      # active_window_opacity = 0.9;
      # normal_window_opacity = 0.8;

      external_bar = "all:40:0";
      window_shadow = "off";
    };

    extraConfig = ''
      # Disable specific apps
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="^Shottr$" manage=off
      yabai -m rule --add app="^ProtonVPN$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add app="^IINA$" manage=off
      yabai -m rule --add app="^WhatsApp$" manage=off
      yabai -m rule --add app="^Vorssaint$" manage=off

      # Mouse focus
      # yabai -m window --focus mouse

      # window opacity
      # yabai -m config window_opacity on
      # yabai -m config active_window_opacity 0.9
      # yabai -m config normal_window_opacity 0.8

      # Sketchybar integration
      # Front App
      yabai -m signal --add event=window_focused \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger window_focus INFO=\"\$(${pkgs.yabai}/bin/yabai -m query --windows --window | ${pkgs.jq}/bin/jq -r '.app')\""

      yabai -m signal --add event=window_created \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger window_focus INFO=\"\$(${pkgs.yabai}/bin/yabai -m query --windows --window | ${pkgs.jq}/bin/jq -r '.app')\""

      yabai -m signal --add event=window_destroyed \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger window_focus INFO=\"\$(${pkgs.yabai}/bin/yabai -m query --windows --window | ${pkgs.jq}/bin/jq -r '.app')\""

      yabai -m signal --add event=window_minimized \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger window_focus INFO=\"\$(${pkgs.yabai}/bin/yabai -m query --windows --window | ${pkgs.jq}/bin/jq -r '.app')\""

      yabai -m signal --add event=space_changed \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger window_focus INFO=\"\$(${pkgs.yabai}/bin/yabai -m query --windows --space | ${pkgs.jq}/bin/jq -r 'map(select(.[\"has-focus\"] == true))[0].app // \"\"')\""

      # Space icons
      yabai -m signal --add event=space_changed \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger space_change"

      yabai -m signal --add event=window_focused \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"

      yabai -m signal --add event=window_created \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"

      yabai -m signal --add event=window_destroyed \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"

      yabai -m signal --add event=window_minimized \
        action="${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
    '';
  };

  launchd.user.agents.yabai.serviceConfig = {
    ProcessType = "Interactive";
    Nice = -20;
    StandardOutPath = "/tmp/yabai.out.log";
    StandardErrorPath = "/tmp/yabai.err.log";
  };
}
