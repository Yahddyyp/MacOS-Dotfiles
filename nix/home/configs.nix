{ config, username, ... }:
let
  repoConfigsDir = "/etc/nix-darwin/configs";
in {
  xdg.configFile."aerospace" = { source = ../configs/aerospace; recursive = true; };
  xdg.configFile."fastfetch"  = { source = ../configs/fastfetch; recursive = true; };
  xdg.configFile."hunk"       = { source = ../configs/hunk;        recursive = true; };
  xdg.configFile."karabiner"  = { source = ../configs/karabiner; recursive = true; };
  xdg.configFile."lazygit"    = { source = ../configs/lazygit;  recursive = true; };
  xdg.configFile."neofetch"   = { source = ../configs/neofetch; recursive = true; };
  xdg.configFile."nushell"    = { source = ../configs/nushell;  recursive = true; };
  xdg.configFile."nvim"       = { source = ../configs/nvim;        recursive = true; };
  xdg.configFile."nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/nvim-lazy-lock.json";
  xdg.configFile."sketchybar" = { source = ../configs/sketchybar; recursive = true; };
  xdg.configFile."spicetify"  = { source = ../configs/spicetify;    recursive = true; };
  xdg.configFile."spicetify/config-xpui.ini".source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/spicetify-config-xpui.ini";
  xdg.configFile."tuicr"      = { source = ../configs/tuicr;      recursive = true; };
  xdg.configFile."zed" = { source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/zed"; };

  home.file.".p10k.zsh"       = { source = ../configs/p10k/.p10k.zsh; };
}
