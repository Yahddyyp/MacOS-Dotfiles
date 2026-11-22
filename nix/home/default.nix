{ pkgs, lib, username, ... }:
{
  imports = [
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
    nmap
    superfile
    container
    podman
    zig
    rustup
    tailscale
    clock-rs
    fetch
    delta
    curl
    python3
    uv
  ];

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  home.file.".hushlogin".text = "";

  programs.home-manager.enable = true;
}
