{ pkgs, username, ... }:
{
  # nix gc daemon
  launchd.daemons.nix-gc-custom = {
    command = "${pkgs.bash}/bin/bash ${../scripts/gc.sh} /Users/${username}";
    serviceConfig.RunAtLoad = true;
    serviceConfig.StartCalendarInterval = [{ Weekday = 0; Hour = 3; Minute = 0; }];
    serviceConfig.StandardOutPath = "/tmp/nix-gc.log";
    serviceConfig.StandardErrorPath = "/tmp/nix-gc.err.log";
  };
}
