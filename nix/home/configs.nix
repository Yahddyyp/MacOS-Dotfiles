{ config, username, ... }:
let
  repoConfigsDir = "/etc/nix-darwin/configs";
in {
  xdg.configFile."fastfetch"  = { source = ../configs/fastfetch; recursive = true; };
  xdg.configFile."neofetch"   = { source = ../configs/neofetch; recursive = true; };
  xdg.configFile."nvim"       = { source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/nvim"; };
  xdg.configFile."sketchybar" = { source = ../configs/sketchybar; recursive = true; };
  xdg.configFile."zed"        = { source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/zed"; };

  home.file.".p10k.zsh"       = { source = ../configs/p10k/.p10k.zsh; };
}
