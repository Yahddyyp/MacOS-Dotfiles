{ pkgs, lib, config, username, ... }:
let
  wmAgentPath = "/run/current-system/sw/bin:/opt/homebrew/bin:/usr/bin:/bin";
in {
  nixpkgs.config = {
    allowUnfree = true;
  };
  system.primaryUser = username;

  environment.systemPackages = with pkgs; [
    sketchybar
    yabai
    skhd
    (pass.withExtensions (exts: with exts; [ pass-otp ]))
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
    command = "${pkgs.yabai}/bin/yabai --load-sa";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = {
      SuccessfulExit = false;
      Crashed = true;
    };
    serviceConfig.StandardOutPath = "/tmp/yabai-sa.out.log";
    serviceConfig.StandardErrorPath = "/tmp/yabai-sa.err.log";
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

  launchd.agents.sketchybar = {
    command = "${pkgs.sketchybar}/bin/sketchybar";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = true;
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Nice = -20;
    serviceConfig.EnvironmentVariables = { PATH = wmAgentPath; };
    serviceConfig.StandardOutPath = "/tmp/sketchybar.out.log";
    serviceConfig.StandardErrorPath = "/tmp/sketchybar.err.log";
  };

  launchd.agents.yabai = {
    command = "${pkgs.yabai}/bin/yabai";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = {
      SuccessfulExit = false;
      Crashed = true;
    };
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Nice = -20;
    serviceConfig.EnvironmentVariables = {
      PATH = wmAgentPath;
      YABAI_CONFIG = "/Users/${username}/.config/yabai/yabairc";
    };
    serviceConfig.StandardOutPath = "/tmp/yabai.out.log";
    serviceConfig.StandardErrorPath = "/tmp/yabai.err.log";
  };

  launchd.agents.skhd = {
    command = "${pkgs.skhd}/bin/skhd -c /Users/${username}/.config/skhd/skhdrc";
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = {
      SuccessfulExit = false;
      Crashed = true;
    };
    serviceConfig.ProcessType = "Interactive";
    serviceConfig.Nice = -20;
    serviceConfig.EnvironmentVariables = { PATH = wmAgentPath; };
    serviceConfig.StandardOutPath = "/tmp/skhd.out.log";
    serviceConfig.StandardErrorPath = "/tmp/skhd.err.log";
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
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
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
      "neofetch"
      "powerlevel10k"
      "hunk"
      "mole"
      "tailscale"
      "tty-clock"
      "zsh-syntax-highlighting"
      "tree-sitter-cli"
      "container"
      "podman"
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

  # Suppress launchctl LaunchAgent/root warnings during activation
  system.activationScripts._launchd = {
    deps = [ ];
    text = ''
      launchctl() { command launchctl "$@" 2>/dev/null; }
      export -f launchctl
    '';
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
    defaults write NSGlobalDomain AppleHighlightColor -string "0.580000 0.530000 0.620000" 2>/dev/null

    # Default apps
    duti -s app.zen-browser.zen public.html all 2>/dev/null
    duti -s app.zen-browser.zen http all 2>/dev/null
    duti -s app.zen-browser.zen https all 2>/dev/null
    duti -s com.colliderli.iina .mp4 all 2>/dev/null
    duti -s com.colliderli.iina .mkv all 2>/dev/null
    duti -s com.colliderli.iina .mov all 2>/dev/null
    duti -s com.colliderli.iina .avi all 2>/dev/null
    duti -s com.colliderli.iina .webm all 2>/dev/null
    duti -s com.colliderli.iina .wmv all 2>/dev/null

    # Default text editor
    for ext in txt md json yaml yml toml xml csv env sh zsh fish py js ts jsx tsx css scss html nix lua rb rs go swift; do
      duti -s dev.zed.Zed .$ext all 2>/dev/null
    done
  '';
  };

  #nix settings
  launchd.daemons.nix-gc-custom = {
    command = "${pkgs.bash}/bin/bash /Users/${username}/dotfiles/nix/gc.sh";
    serviceConfig.RunAtLoad = false;
    serviceConfig.StartCalendarInterval = [{ Weekday = 0; }];  # Sunday
    serviceConfig.StandardOutPath = "/tmp/nix-gc.log";
    serviceConfig.StandardErrorPath = "/tmp/nix-gc.err.log";
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    builders-use-substitutes = true;
    auto-optimise-store = true;
    warn-dirty = false;
  };
}
