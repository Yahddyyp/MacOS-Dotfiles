{ pkgs, username, ... }:
let
  wmAgentPath = "/run/current-system/sw/bin:/opt/homebrew/bin:/usr/bin:/bin";
in {
  # launchd daemon for yabai scripting addon
  launchd.daemons.yabai-sa = {
    command = "${pkgs.yabai}/bin/yabai --load-sa";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = {
      SuccessfulExit = false;
      Crashed = true;
    };
    serviceConfig.StandardOutPath = "/tmp/yabai-sa.out.log";
    serviceConfig.StandardErrorPath = "/tmp/yabai-sa.err.log";
  };

  # Disable Caps Lock so Karabiner can intercept it
  launchd.agents.capslock-disable = {
    command = ''
      /usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0}]}' > /dev/null 2>&1
    '';
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = false;
    serviceConfig.StandardOutPath = "/tmp/capslock-disable.log";
    serviceConfig.StandardErrorPath = "/tmp/capslock-disable.err.log";
  };

  # sketchybar plist
  launchd.agents.sketchybar = {
    command = "/bin/sh -c '/bin/wait4path /run/current-system/sw/bin/sketchybar && exec ${pkgs.sketchybar}/bin/sketchybar'";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = true;
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Nice = -20;
    serviceConfig.EnvironmentVariables = { PATH = wmAgentPath; };
    serviceConfig.StandardOutPath = "/tmp/sketchybar.out.log";
    serviceConfig.StandardErrorPath = "/tmp/sketchybar.err.log";
  };

  # yabai plist
  launchd.agents.yabai = {
    command = "/bin/sh -c '/bin/wait4path /run/current-system/sw/bin/yabai && exec ${pkgs.yabai}/bin/yabai'";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = {
      SuccessfulExit = false;
      Crashed = true;
    };
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Nice = -20;
    serviceConfig.EnvironmentVariables = {
      PATH = wmAgentPath;
      YABAI_CONFIG = "/Users/${username}/.config/yabai/yabairc";
    };
    serviceConfig.StandardOutPath = "/tmp/yabai.out.log";
    serviceConfig.StandardErrorPath = "/tmp/yabai.err.log";
  };

  #skhd plist
  launchd.agents.skhd = {
    command = "/bin/sh -c '/bin/wait4path /run/current-system/sw/bin/skhd && exec ${pkgs.skhd}/bin/skhd -c /Users/${username}/.config/skhd/skhdrc'";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = {
      SuccessfulExit = false;
      Crashed = true;
    };
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Nice = -20;
    serviceConfig.EnvironmentVariables = { PATH = wmAgentPath; };
    serviceConfig.StandardOutPath = "/tmp/skhd.out.log";
    serviceConfig.StandardErrorPath = "/tmp/skhd.err.log";
  };

  #nix gc daemon 
  launchd.daemons.nix-gc-custom = {
    command = "${pkgs.bash}/bin/bash /Users/${username}/dotfiles/nix/scripts/gc.sh /Users/${username}";
    serviceConfig.RunAtLoad = true;
    serviceConfig.StartCalendarInterval = [{ Weekday = 0; Hour = 3; Minute = 0; }];
    serviceConfig.StandardOutPath = "/tmp/nix-gc.log";
    serviceConfig.StandardErrorPath = "/tmp/nix-gc.err.log";
  };
}
