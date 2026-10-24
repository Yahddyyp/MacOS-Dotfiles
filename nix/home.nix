{ pkgs, lib, username, ... }:
{
  imports = [
    ./modules/git.nix
    ./modules/gh.nix
    ./modules/gpg.nix
    ./modules/activation.nix
    ./modules/configs.nix
    ./modules/sketchybar.nix
    ./modules/bat.nix
    ./modules/btop.nix
    ./modules/eza.nix
    ./modules/kitty.nix
    ./modules/ghostty.nix
  ];

  home.username = username;
  home.homeDirectory = lib.mkForce (builtins.toPath ("/Users/" + username));

  home.stateVersion = "24.11";

  # home packages
  home.packages = with pkgs; [
    fish
    tmux
    neovim
    starship
    bun
    nodejs
    atuin
    bandwhich
    fastfetch
    yazi
    fd
    ripgrep
    tree
    zoxide
    fzf
    lazygit
    stow
    delta
    duf
    dust
    gdu
    ouch
    _7zz
    ffmpeg
    imagemagick
    jq
    just
    pinentry-curses
    luarocks
    ngrok
    cbonsai
    sesh
    pi-coding-agent
    lua
    spicetify-cli
    gh-dash
    television
    gum
    nushell
    herdr
    nmap
    superfile
    tuicr
    hunk
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  programs.home-manager.enable = true;
}
