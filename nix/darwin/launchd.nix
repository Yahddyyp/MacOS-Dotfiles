{ pkgs, username, ... }:
{
  # Disable caps lock so karabiner can intercept it.
  launchd.agents.capslock-disable = {
    command = ''
      /usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0}]}'
    '';

    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/capslock-disable.log";
      StandardErrorPath = "/tmp/capslock-disable.err.log";
    };
  };

  # Nix gc daemon
  launchd.daemons.nix-gc-custom = {
    command = "${pkgs.bash}/bin/bash ${../scripts/gc.sh} /Users/${username}";
    serviceConfig = {
      RunAtLoad = true;
      StartCalendarInterval = [{ Weekday = 0; Hour = 3; Minute = 0; }];
      StandardOutPath = "/tmp/nix-gc.log";
      StandardErrorPath = "/tmp/nix-gc.err.log";
    };
  };
}
