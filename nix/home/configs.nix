{ config, username, ... }:
let
  repoConfigsDir = "/etc/nix-darwin/configs";
in {
  xdg.configFile."aerospace" = { source = ../configs/aerospace; recursive = true; };
  xdg.configFile."fastfetch"  = { source = ../configs/fastfetch; recursive = true; };
  xdg.configFile."hunk"       = { source = ../configs/hunk;        recursive = true; };
  xdg.configFile."lazygit"    = { source = ../configs/lazygit;  recursive = true; };
  xdg.configFile."neofetch"   = { source = ../configs/neofetch; recursive = true; };
  xdg.configFile."nushell"    = { source = ../configs/nushell;  recursive = true; };
  xdg.configFile."nvim"       = { source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/nvim"; };
  xdg.configFile."sketchybar" = { source = ../configs/sketchybar; recursive = true; };
  xdg.configFile."spicetify"  = { source = ../configs/spicetify;    recursive = true; };
  xdg.configFile."tuicr"      = { source = ../configs/tuicr;      recursive = true; };
  xdg.configFile."zed"        = { source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/zed"; };

  home.file.".p10k.zsh"       = { source = ../configs/p10k/.p10k.zsh; };
}
