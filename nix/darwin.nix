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
    _FXShowPosixPathInTitle = false;
    _FXSortFoldersFirst = true;
    CreateDesktop = true;
    ShowHardDrivesOnDesktop = false;
    ShowExternalHardDrivesOnDesktop = false;
    FXEnableExtensionChangeWarning = false;
    FXRemoveOldTrashItems = true;
  };

  #WM settings
  system.defaults.WindowManager = {
    EnableStandardClickToShowDesktop = false;  
    GloballyEnabled = false;                     
    StandardHideDesktopIcons = true;              
    HideDesktop = true;                          
  };

  #Trackpad settings
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
    FirstClickThreshold = 0;
    SecondClickThreshold = 2;
  };

  #Some other settings
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
      "duti"
      "mole"
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

  system.activationScripts.defaultApps = {
    deps = [ "homebrew-install" ];
    text = ''
    # Disable ⌘Space
    for user_home in /Users/${username}; do
      plist="$user_home/Library/Preferences/com.apple.symbolichotkeys.plist"
      if [ -f "$plist" ]; then
        /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" "$plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64:enabled bool false" "$plist"
        /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:65:enabled false" "$plist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:65:enabled bool false" "$plist"
      fi
    done

    # Set accent highlight color 
    defaults write NSGlobalDomain AppleHighlightColor -string "0.580000 0.530000 0.620000"

    # Default browser
    duti -s app.zen-browser.zen public.html all
    duti -s app.zen-browser.zen http all
    duti -s app.zen-browser.zen https all

    # Default video player
    duti -s com.colliderli.iina .mp4 all
    duti -s com.colliderli.iina .mkv all
    duti -s com.colliderli.iina .mov all
    duti -s com.colliderli.iina .avi all
    duti -s com.colliderli.iina .webm all
    duti -s com.colliderli.iina .wmv all

    # IINA
    defaults write com.colliderli.iina resizeWindowTiming -int 0

    # Default text editor
    duti -s dev.zed.Zed .txt all
    duti -s dev.zed.Zed .md all
    duti -s dev.zed.Zed .json all
    duti -s dev.zed.Zed .yaml all
    duti -s dev.zed.Zed .yml all
    duti -s dev.zed.Zed .toml all
    duti -s dev.zed.Zed .xml all
    duti -s dev.zed.Zed .csv all
    duti -s dev.zed.Zed .env all
    duti -s dev.zed.Zed .sh all
    duti -s dev.zed.Zed .zsh all
    duti -s dev.zed.Zed .fish all
    duti -s dev.zed.Zed .py all
    duti -s dev.zed.Zed .js all
    duti -s dev.zed.Zed .ts all
    duti -s dev.zed.Zed .jsx all
    duti -s dev.zed.Zed .tsx all
    duti -s dev.zed.Zed .css all
    duti -s dev.zed.Zed .scss all
    duti -s dev.zed.Zed .html all
    duti -s dev.zed.Zed .nix all
    duti -s dev.zed.Zed .lua all
    duti -s dev.zed.Zed .rb all
    duti -s dev.zed.Zed .rs all
    duti -s dev.zed.Zed .go all
    duti -s dev.zed.Zed .swift all
  '';
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
