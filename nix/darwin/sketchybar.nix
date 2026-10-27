{ pkgs, ... }:
{
  services.sketchybar = {
    enable = true;
    extraPackages = [
      pkgs.lua5_5
      pkgs.sbarlua
    ];
  };

  launchd.user.agents.sketchybar.serviceConfig = {
    ProcessType = "Interactive";
    StandardOutPath = "/tmp/sketchybar.out.log";
    StandardErrorPath = "/tmp/sketchybar.err.log";
    EnvironmentVariables = {
      LUA_CPATH = "${pkgs.sbarlua}/lib/lua/5.5/?.so;;";
    };
  };
}
