{ pkgs, username, ... }:
let
  wmAgentPath = "/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/sbin:/sbin:/usr/bin:/bin";
in {
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

  # sketchybar plist
  launchd.agents.sketchybar = {
    command = "${pkgs.sketchybar}/bin/sketchybar";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = true;
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Nice = -20;
    serviceConfig.EnvironmentVariables = {
      PATH = "${pkgs.lua5_5}/bin:${wmAgentPath}";
      CONFIG_DIR = "/Users/${username}/.config/sketchybar";
      LUA_CPATH = "${pkgs.sbarlua}/lib/lua/5.5/?.so;;";
    };
    serviceConfig.StandardOutPath = "/tmp/sketchybar.out.log";
    serviceConfig.StandardErrorPath = "/tmp/sketchybar.err.log";
  };

  # nix gc daemon
  launchd.daemons.nix-gc-custom = {
    command = "${pkgs.bash}/bin/bash ${../scripts/gc.sh} /Users/${username}";
    serviceConfig.RunAtLoad = true;
    serviceConfig.StartCalendarInterval = [{ Weekday = 0; Hour = 3; Minute = 0; }];
    serviceConfig.StandardOutPath = "/tmp/nix-gc.log";
    serviceConfig.StandardErrorPath = "/tmp/nix-gc.err.log";
  };
}
