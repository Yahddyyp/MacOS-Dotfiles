{ config, lib, pkgs, ... }:
let
  cfg = config.services.sketchybar;
in
{
  options.services.sketchybar = {
    configType = lib.mkOption {
      type = lib.types.enum [ "bash" "lua" ];
      default = "lua";
      description = "The type of configuration for sketchybar.";
    };

    sbarLuaPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.sbarlua;
      description = "Lua bindings package for sketchybar.";
    };

    luaPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.lua5_5;
      description = "Lua interpreter package.";
    };
  };

  config = {
    services.sketchybar = {
      enable = true;
      configType = "lua";
      sbarLuaPackage = pkgs.sbarlua;
      luaPackage = pkgs.lua5_5;

      extraPackages = lib.optionals (cfg.configType == "lua") [
        cfg.luaPackage
        cfg.sbarLuaPackage
      ];
    };

    launchd.user.agents.sketchybar.serviceConfig = lib.mkIf cfg.enable {
      ProcessType = "Interactive";
      StandardOutPath = "/tmp/sketchybar.out.log";
      StandardErrorPath = "/tmp/sketchybar.err.log";
      EnvironmentVariables = lib.mkIf (cfg.configType == "lua" && cfg.sbarLuaPackage != null) {
        LUA_CPATH = "${cfg.sbarLuaPackage}/lib/lua/${cfg.luaPackage.luaversion}/?.so;;";
      };
    };
  };
}
