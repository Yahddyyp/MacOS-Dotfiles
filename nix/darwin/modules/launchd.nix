{ pkgs, username, ... }:
{
  # Nix garbage collection script
  launchd.daemons.nix-gc-custom = {
    command = "${pkgs.bash}/bin/bash ${../../scripts/gc.sh} /Users/${username}";
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 3;
          Minute = 0;
        }
      ];
      StandardOutPath = "/tmp/nix-gc.log";
      StandardErrorPath = "/tmp/nix-gc.err.log";
    };
  };
}
