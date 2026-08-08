{ lib, pkgs, username, ... }:
{
  imports = [ ./modules/macos.nix ./modules/launchd.nix ];

  nixpkgs.config = {
    allowUnfree = true;
  };
  system.primaryUser = username;

  # Cloudflare DNS
  networking = {
    knownNetworkServices = [ "Wi-Fi" ];
    dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  };

  environment.systemPackages = with pkgs; [
    sketchybar
    yabai
    skhd
    (pass.withExtensions (exts: with exts; [ pass-otp pass-audit pass-update ]))
    gnupg
    carapace
    duti
    switchaudio-osx
  ];

  # Homebrew env variables
  environment.variables = {
    HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
    HOMEBREW_NO_AUTO_UPDATE = "1";
    HOMEBREW_NO_ENV_HINTS = "1";
  };

  users.users.${username} = {
    shell = pkgs.zsh;
  };
  system.stateVersion = 5;

  # font
  fonts.packages = with pkgs; [ 
    nerd-fonts.caskaydia-cove  
    maple-mono.truetype
    maple-mono.NF-unhinted
  ];

  environment.loginShellInit = ''
    # Run path_helper to load system PATH 
    if [ -x /usr/libexec/path_helper ]; then
      eval "$(/usr/libexec/path_helper -s)"
    fi
  '';

  system.activationScripts.preActivation.text = lib.mkAfter ''
    # Suppress launchctl LaunchAgent root warnings during activation
    launchctl() { command launchctl "$@" 2>/dev/null; }
    export -f launchctl
  '';

  # Homebrew installation manager
  nix-homebrew = {
    enable = true;
    user = username;
    autoMigrate = true;
  };

  # Homebrew settings
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
      extraEnv = {
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
        HOMEBREW_NO_AUTO_UPDATE = "1";
      };
    };

    taps = [
      "FelixKratz/formulae"
      "koekeishiya/formulae"
      "nikitabobko/tap"
      "modem-dev/tap"
      "agavra/tap"
    ];

    brews = [
      "borders"
      "neofetch"
      "powerlevel10k"
      "hunk"
      "mole"
      "tailscale"
      "tty-clock"
      "zsh-syntax-highlighting"
      "container"
      "podman"
      "zig"
      "rustup"
      "tuicr"
    ];

    casks = [
      "kitty"
      "zed"
      "aerospace"
      "obsidian"
      "iina"
      "localsend"
      "karabiner-elements"
      "ghostty"
      "raycast"
      "spotify"
      "clop"
      "zen"
      "kindavim"
      "vesktop"
      "protonvpn"
      "font-sketchybar-app-font"
      "anki"
      "osu"
      "vorssaint"
    ];
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    builders-use-substitutes = true;
    warn-dirty = false;
  };

  nix.optimise.automatic = true;
}
