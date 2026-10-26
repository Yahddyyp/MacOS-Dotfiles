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

  xdg.enable = true;

  # home packages
  home.packages = with pkgs; [
    neovim
    bun
    nodejs
    bandwhich
    fastfetch
    fd
    ripgrep
    tree
    stow
    duf
    dust
    gdu
    ouch
    _7zz
    ffmpeg
    imagemagick
    jq
    just
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
    container
    podman
    zig
    rustup
    tailscale
    clock-rs
    fetch
    tuios
    delta
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  home.file.".hushlogin".text = "";

  programs.home-manager.enable = true;
}
