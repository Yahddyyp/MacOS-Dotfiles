{ pkgs, lib, username, ... }:
{
  imports = [
    ./activation.nix
    ./configs.nix
    ./modules
  ];

  home.username = username;
  home.homeDirectory = lib.mkForce (builtins.toPath ("/Users/" + username));

  home.stateVersion = "24.11";

  # home packages
  home.packages = with pkgs; [
    neovim
    starship
    bun
    nodejs
    bandwhich
    fastfetch
    fd
    ripgrep
    tree
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
    pi-coding-agent
    lua
    spicetify-cli
    gum
    nushell
    nmap
    superfile
    tuicr
    hunk
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  home.file.".hushlogin".text = "";

  programs.home-manager.enable = true;
}
