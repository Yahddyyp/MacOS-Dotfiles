{ lib, pkgs, username, ... }:
{
  imports = [ ./modules/macos.nix ./modules/launchd.nix ];

  nixpkgs.config = {
    allowUnfree = true;
  };
  system.primaryUser = username;

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

  # Homebrew trust
  environment.variables = {
    HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
  };

  users.users.${username} = {
    shell = pkgs.zsh;
  };
  system.stateVersion = 5;

  #font
  fonts.packages = with pkgs; [ 
    nerd-fonts.caskaydia-cove  
    maple-mono.truetype
    maple-mono.NF-unhinted
  ];

  environment.loginShellInit = ''
    # Run path_helper to load system PATH (/etc/paths, /etc/paths.d/*)
    if [ -x /usr/libexec/path_helper ]; then
      eval "$(/usr/libexec/path_helper -s)"
    fi
  '';

  system.activationScripts.preActivation.text = lib.mkAfter ''
    # Suppress launchctl LaunchAgent/root warnings during activation
    launchctl() { command launchctl "$@" 2>/dev/null; }
    export -f launchctl

    # Auto-install Homebrew if not present
    if [ ! -f /opt/homebrew/bin/brew ]; then
      echo "Homebrew not found. Installing Homebrew non-interactively..."
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  '';

  #Homebrew settings
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
      extraEnv = {
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
        HOMEBREW_NO_AUTO_UPDATE = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
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
      "shottr"
    ];
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    builders-use-substitutes = true;
    warn-dirty = false;
  };

  nix.optimise.automatic = true;
}
