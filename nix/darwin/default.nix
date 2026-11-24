{ pkgs, username, ... }:
{
  imports = [
    ./borders.nix
    ./launchd.nix
    ./macos.nix
    ./sketchybar.nix
    ./skhd.nix
    ./yabai.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  system.primaryUser = username;

  # Cloudflare DNS
  networking = {
    knownNetworkServices = [ "Wi-Fi" ];
    dns = [ "1.1.1.1" "1.0.0.1" ];
  };

  environment.systemPackages = with pkgs; [
    duti
    iina
    kitty
    obsidian
    libreoffice-bin
    ghostty-bin
    handy
    zed-editor
    osu-lazer-bin
    firefox
  ];

  # Homebrew env variables
  environment.variables = {
    HOMEBREW_NO_AUTO_UPDATE = "1";
    HOMEBREW_NO_ENV_HINTS = "1";
  };

  users.users.${username} = {
    shell = pkgs.zsh;
  };
  system.stateVersion = 5;

  # font
  fonts.packages = with pkgs; [
    maple-mono.NF-unhinted
    sketchybar-app-font
  ];

  environment.loginShellInit = ''
    # Run path_helper to load system PATH
    if [ -x /usr/libexec/path_helper ]; then
      eval "$(/usr/libexec/path_helper -s)"
    fi
  '';


  # Homebrew installation manager
  nix-homebrew = {
    enable = true;
    user = username;
    autoMigrate = true;
    trust.taps = [
      "raine/workmux"
      "nikitabobko/tap"
      "omlahore/tap"
    ];
  };

  # Homebrew settings
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };

    taps = [
      "raine/workmux"
      "nikitabobko/tap"
      "omlahore/tap"
    ];

    brews = [
      "neofetch"
      "mole"
      "workmux"
      "removemacai"
    ];

    casks = [
      "localsend"
      "raycast"
      "zen"
      "kindavim"
      "vesktop"
      "protonvpn"
      "anki"
      "vorssaint"
      "steam"
      "karabiner-elements"
      "helium-browser"
      "macpacker"
    ];
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    builders-use-substitutes = true;
    warn-dirty = false;
  };

  nix.optimise.automatic = true;
}
