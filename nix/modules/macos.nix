{ lib, username, ... }:
{
  # dock settings
  system.defaults.dock = {
    orientation = "right";
    autohide-delay = 0.0;
    autohide = true;
    mru-spaces = false;
    show-recents = false;
    static-only = false;
    mineffect = "scale";
    tilesize = 42;
    autohide-time-modifier = 0.0;
    magnification = false;
    showhidden = true;
  };

  # finder settings
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
    ShowRemovableMediaOnDesktop = false;
    ShowMountedServersOnDesktop = false;
    NewWindowTarget = "Home";
    FXEnableExtensionChangeWarning = false;
    FXRemoveOldTrashItems = true;
  };

  # WM settings
  system.defaults.WindowManager = {
    EnableStandardClickToShowDesktop = false;
    GloballyEnabled = false;
    StandardHideDesktopIcons = true;
    StandardHideWidgets = false;
    HideDesktop = true;
  };

  # Trackpad settings
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
    TrackpadThreeFingerDrag = true;
    FirstClickThreshold = 0;
    SecondClickThreshold = 2;
  };

  # Some other settings
  system.defaults.NSGlobalDomain = {
    KeyRepeat = 2;
    InitialKeyRepeat = 15;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSDocumentSaveNewDocumentsToCloud = false;
    AppleKeyboardUIMode = 3;
    ApplePressAndHoldEnabled = false;
    "com.apple.trackpad.scaling" = 2.5;
    "com.apple.swipescrolldirection" = true;
    _HIHideMenuBar = true;
  };

  # screencapture settings
  system.defaults.screencapture = {
    type = "jpg";
    disable-shadow = true;
  };

  # controlcenter settings
  system.defaults.controlcenter = {
    BatteryShowPercentage = true;
  };

  # system defaults
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
        FinderSpawnTab = false;
        QLEnableTextSelection = true;
      };
      "com.apple.desktopservices" = {
        DSDontShowBackgroundImage = false;
        DSDontWriteUSBStores = true;
        DSDontWriteNetworkStores = true;
      };
      "com.apple.frameworks.diskimages" = {
        skip-verify = true;
        skip-verify-locked = true;
        skip-verify-remote = true;
      };
      "com.apple.CrashReporter" = {
        DialogType = "none";
      };
      "com.apple.AdLib" = {
        forceLimitAdTracking = true;
        allowApplePersonalizedAdvertising = false;
        allowIdentifierForAdvertising = false;
      };
      "com.apple.screensaver" = {
        idleTime = 600;  # 10 min
      };
      "com.apple.loginwindow" = {
        TALogoutSavesState = false;
        SHOWFULLNAME = true;
      };
    };
  };

  # Inactive time
  power = {
    sleep = {
      computer = 20;
      display = 20;
    };
  };

  # Touch ID for sudo
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Keep SSH open
  services.openssh.enable = true;

  system.activationScripts.postActivation.text = lib.mkAfter ''
    user_home="/Users/${username}"
    run_as_user() {
      sudo -u "${username}" HOME="$user_home" "$@"
    }

    # Mute startup chime
    nvram StartupMute=%01 2>/dev/null || true

    # Display sleep 15 min on battery
    /usr/bin/pmset -b displaysleep 15

    # Disable ⌘Space
    plist="$user_home/Library/Preferences/com.apple.symbolichotkeys.plist"
    if [ -f "$plist" ]; then
      run_as_user /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" "$plist" 2>/dev/null \
        || run_as_user /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64:enabled bool false" "$plist"
      run_as_user /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:65:enabled false" "$plist" 2>/dev/null \
        || run_as_user /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:65:enabled bool false" "$plist"
    fi

    # Set accent highlight color
    run_as_user defaults write NSGlobalDomain AppleHighlightColor -string "0.580000 0.530000 0.620000" 2>/dev/null

    # Default apps
    for app in /Applications/Zen.app /Applications/IINA.app /Applications/Zed.app; do
      [ -d "$app" ] && run_as_user /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app" 2>/dev/null
    done
    run_as_user duti -s app.zen-browser.zen public.html all 2>/dev/null
    run_as_user duti -s app.zen-browser.zen http all 2>/dev/null
    run_as_user duti -s app.zen-browser.zen https all 2>/dev/null
    run_as_user duti -s com.colliderli.iina .mp4 all 2>/dev/null
    run_as_user duti -s com.colliderli.iina .mkv all 2>/dev/null
    run_as_user duti -s com.colliderli.iina .mov all 2>/dev/null
    run_as_user duti -s com.colliderli.iina .avi all 2>/dev/null
    run_as_user duti -s com.colliderli.iina .webm all 2>/dev/null
    run_as_user duti -s com.colliderli.iina .wmv all 2>/dev/null

    # Default text editor
    for ext in txt md json yaml yml toml xml csv env sh zsh fish py js ts jsx tsx css scss html nix lua rb rs go swift; do
      run_as_user duti -s dev.zed.Zed .$ext all 2>/dev/null
    done

    run_as_user killall cfprefsd 2>/dev/null || true
  '';
}
