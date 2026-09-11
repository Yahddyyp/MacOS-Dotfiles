{ config, pkgs, ... }:
{
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    sbarLuaPackage = pkgs.sbarlua;
    luaPackage = pkgs.lua5_5;
    service.enable = false;
  };
}
