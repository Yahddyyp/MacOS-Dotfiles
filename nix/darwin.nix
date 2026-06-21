{ pkgs, lib, config, username, ... }: {
  #Allow broken and free pkgs 
  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };
  system.primaryUser = username;

  environment.systemPackages = with pkgs; [
  ];

  # Homebrew trust
  environment.variables = {
    HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
  };

  users.users.${username} = {
    shell = pkgs.zsh;
  };
  system.stateVersion = 5;
  
  #dock settings
  system.defaults.dock = {
    orientation = "right";
    autohide-delay = 0.0;
    autohide = true;
    show-recents = false;
    static-only = false;
    mineffect = "scale";
    tilesize = 42;
  };

  #finder settings
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    AppleShowAllFiles = true;
    FXPreferredViewStyle = "Nlsv";
    ShowPathbar = true;
    ShowStatusBar = true;
    FXDefaultSearchScope = "SCcf";
    QuitMenuItem = true;
    _FXShowPosixPathInTitle = true;
    _FXSortFoldersFirst = true;
    CreateDesktop = true;
    FXEnableExtensionChangeWarning = false;
    FXRemoveOldTrashItems = true;
  };

  #WM settings
  system.defaults.WindowManager = {
    EnableStandardClickToShowDesktop = false;
    GloballyEnabled = false;
    StandardHideDesktopIcons = true;
  };

  #Trackpad settings
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
    FirstClickThreshold = 0;
    SecondClickThreshold = 2;
  };

  #Some otheer settings
  system.defaults.NSGlobalDomain = {
    KeyRepeat = 2;
    InitialKeyRepeat = 15;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSDocumentSaveNewDocumentsToCloud = false;
    "com.apple.trackpad.scaling" = 2.5;
    "com.apple.swipescrolldirection" = true;
    _HIHideMenuBar = true;
  };

  #screencapture settings
  system.defaults.screencapture = {
    type = "jpg";
  };

  #controlcenter settings
  system.defaults.controlcenter = {
    BatteryShowPercentage = true;
  };

  #system defaults
  system.defaults = {
    LaunchServices.LSQuarantine = false;
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
    CustomUserPreferences = {
      "NSGlobalDomain" = {
        AppleAccentColor = 5;
        AppleInterfaceStyle = "Dark";
        AppleShowScrollBars = "WhenScrolling";
        AppleScrollerPagingBehavior = true;
        AppleWidgetStyle = "automatic";
      };
      # bottom-right hot corner: Hyper (⌃⌥⇧⌘) + corner -> Lock Screen
      # modifier = 131072(shift) + 262144(ctrl) + 524288(alt) + 1048576(cmd) = 1966080
      "com.apple.dock" = {
        wvous-br-corner = 13;
        wvous-br-modifier = 1966080;
      };
      "com.apple.universalaccess" = {
        reduceMotion = true;
      };
      "com.apple.finder" = {
        FKAppearanceMode = 1;
      };
      "com.apple.DesktopServices" = {
        DSDontShowBackgroundImage = false;
      };
    };
  };

  #keep ssh open
  services.openssh.enable = true;

  #touch id for sudo 
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  #Inactive time 
  power = {
    sleep = {
      computer = 10;
      display = 10;
    };
  };

  #font
  fonts.packages = with pkgs; [ nerd-fonts.caskaydia-cove ];

  #launchd daemon for yabai scripting addon
  launchd.daemons.yabai-sa = {
    command = "/opt/homebrew/bin/yabai --load-sa";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = {
      SuccessfulExit = false;
      Crashed = true;
    };
  };

  # Disable Caps Lock so Karabiner can intercept it
  launchd.agents.capslock-disable = {
    command = ''
      /usr/bin/hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0}]}' > /dev/null 2>&1
    '';
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = false;
    serviceConfig.StandardOutPath = "/tmp/capslock-disable.log";
    serviceConfig.StandardErrorPath = "/tmp/capslock-disable.err.log";
  };

  environment.loginShellInit = ''
    # Run path_helper to load system PATH (/etc/paths, /etc/paths.d/*)
    if [ -x /usr/libexec/path_helper ]; then
      eval "$(/usr/libexec/path_helper -s)"
    fi
  '';

  # Auto-install Homebrew if not present
  system.activationScripts.homebrew-install = {
    text = ''
      if [ ! -f /opt/homebrew/bin/brew ]; then
        echo "Homebrew not found. Installing Homebrew non-interactively..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';
    deps = [];
  };

  #Homebrew settings
  homebrew = {
    enable = true;
    onActivation = {
      extraEnv = {
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
      };
    };

    taps = [
      "FelixKratz/formulae"
      "koekeishiya/formulae"
      "nikitabobko/tap"
      "modem-dev/tap"
    ];

    brews = [
      "borders"
      "sketchybar"
      "yabai"
      "skhd"
      "pass"
      "pass-otp"
      "gnupg"           
      "neofetch"
      "switchaudio-osx"
      "zsh-syntax-highlighting"
      "powerlevel10k"
      "tty-clock"
      "tree-sitter-cli"
      "hunk"
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
      "alt-tab"
      "shottr"
      "clop"
      "appcleaner"
      "zen"
      "kindavim"
      "vesktop"
      "stats"
      "finetune"
      "latest"
      "protonvpn"
      "font-sketchybar-app-font"
    ];
  };

  #nix settings
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; };  # weekly (Sunday)
    options = "--delete-generations +3";  # keep the last 3 generations
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    builders-use-substitutes = true;
    auto-optimise-store = true;
  };
}
