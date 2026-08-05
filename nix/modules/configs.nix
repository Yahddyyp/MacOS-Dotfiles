{ config, username, ... }:
let
  repoConfigsDir = "/etc/nix-darwin/configs";
in {
  xdg.configFile."aerospace" = { source = ../configs/aerospace; recursive = true; };
  xdg.configFile."atuin"      = { source = ../configs/atuin;      recursive = true; };
  xdg.configFile."bat"        = { source = ../configs/bat;          recursive = true; };
  xdg.configFile."borders"    = { source = ../configs/borders;  recursive = true; };
  xdg.configFile."btop"       = { source = ../configs/btop;        recursive = true; };
  xdg.configFile."eza"        = { source = ../configs/eza;          recursive = true; };
  xdg.configFile."fastfetch"  = { source = ../configs/fastfetch; recursive = true; };
  xdg.configFile."fish"       = { source = ../configs/fish;        recursive = true; };
  xdg.configFile."gh-dash"    = { source = ../configs/gh-dash;  recursive = true; };
  xdg.configFile."ghostty"    = { source = ../configs/ghostty;  recursive = true; };
  xdg.configFile."herdr"      = { source = ../configs/herdr;      recursive = true; };
  xdg.configFile."hunk"       = { source = ../configs/hunk;        recursive = true; };
  xdg.configFile."karabiner"  = { source = ../configs/karabiner; recursive = true; };
  xdg.configFile."kitty"      = { source = ../configs/kitty;      recursive = true; };
  xdg.configFile."lazygit"    = { source = ../configs/lazygit;  recursive = true; };
  xdg.configFile."neofetch"   = { source = ../configs/neofetch; recursive = true; };
  xdg.configFile."nushell"    = { source = ../configs/nushell;  recursive = true; };
  xdg.configFile."nvim"       = { source = ../configs/nvim;        recursive = true; };
  xdg.configFile."nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/nvim-lazy-lock.json";
  xdg.configFile."opencode"   = { source = ../configs/opencode; recursive = true; };
  xdg.configFile."sesh"       = { source = ../configs/sesh;        recursive = true; };
  xdg.configFile."sketchybar" = { source = ../configs/sketchybar; recursive = true; };
  xdg.configFile."skhd"       = { source = ../configs/skhd;        recursive = true; };
  xdg.configFile."spicetify"  = { source = ../configs/spicetify;    recursive = true; };
  xdg.configFile."spicetify/config-xpui.ini".source = config.lib.file.mkOutOfStoreSymlink "${repoConfigsDir}/spicetify-config-xpui.ini";
  xdg.configFile."starship.toml".source = ../configs/starship.toml;
  xdg.configFile."television" = { source = ../configs/television; recursive = true; };
  xdg.configFile."tuicr"      = { source = ../configs/tuicr;      recursive = true; };
  xdg.configFile."yabai"      = { source = ../configs/yabai;      recursive = true; };
  xdg.configFile."yazi"       = { source = ../configs/yazi;        recursive = true; };
  xdg.configFile."zed"        = { source = ../configs/zed;          recursive = true; };
  xdg.configFile."zsh/zsh-syntax-highlighting/themes" = { source = ../configs/zsh/zsh-syntax-highlighting/themes; recursive = true; };

  home.file.".hushlogin"      = { source = ../configs/home/.hushlogin; };
  home.file.".p10k.zsh"       = { source = ../configs/p10k/.p10k.zsh; };
  home.file.".hermes/config.yaml" = { source = ../configs/hermes/.hermes/config.yaml; };
  home.file.".hermes/skins"       = { source = ../configs/hermes/.hermes/skins; recursive = true; };
  home.file.".tmux.conf"      = { source = ../configs/tmux/.tmux.conf; };
  home.file.".zshrc"          = { source = ../configs/zsh/.zshrc; };
  home.file.".oh-my-zsh/custom" = { source = ../configs/ohmyzsh/.oh-my-zsh/custom; recursive = true; };
}
