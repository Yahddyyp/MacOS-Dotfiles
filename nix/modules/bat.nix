{ config, pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
  };

  catppuccin.bat = {
    enable = true;
    flavor = "mocha";
  };
}
