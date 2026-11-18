{ lib, pkgs, username, ... }:
let
  mk = id: items: lib.concatMapStrings (i: "${id} ${i} all\n") items;
  ext = map (e: ".${e}");
  dutiSettings = pkgs.writeText "duti-settings" (
    mk "app.zen-browser.zen" [ "public.html" "http" "https" ]
    + mk "com.colliderli.iina" (ext [ "mp4" "mkv" "mov" "avi" "webm" "wmv" ])
    + mk "com.sarensx.MacPacker" [ ".zip" ]
    + mk "dev.zed.Zed" (ext [ "txt" "md" "json" "yaml" "yml" "toml" "xml" "csv" "env" "sh" "zsh" "fish" "py" "js" "ts" "jsx" "tsx" "css" "scss" "html" "nix" "lua" "rb" "rs" "go" "swift" ])
  );
in
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
    minimize-to-application = true;
    tilesize = 42;
    autohide-time-modifier = 0.0;
    magnification = false;
    showhidden = true;
    launchanim = false;
    expose-animation-duration = 0.0;
    expose-group-apps = true;
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
    _FXSortFoldersFirstOnDesktop = true;
    CreateDesktop = false;
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
    SecondClickThreshold = 0;
    TrackpadMomentumScroll = true;
    TrackpadTwoFingerDoubleTapGesture = true;
    TrackpadPinch = true;
    TrackpadRotate = true;
    TrackpadFourFingerPinchGesture = 2;
    TrackpadFourFingerHorizSwipeGesture = 2;
    TrackpadFourFingerVertSwipeGesture = 2;
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
    "com.apple.trackpad.forceClick" = false;
    "com.apple.swipescrolldirection" = true;
    NSWindowResizeTime = 0.001;
    _HIHideMenuBar = true;
    NSAutomaticWindowAnimationsEnabled = false;
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
  };

  # Make Fn key do nothing
  system.defaults.hitoolbox.AppleFnUsageType = "Do Nothing";

  # Reduce motion and transparency
  system.defaults.universalaccess = {
    reduceMotion = true;
    reduceTransparency = true;
  };

  # screencapture settings
  system.defaults.screencapture = {
    type = "jpg";
    disable-shadow = true;
    include-date = false;
  };

  # controlcenter settings
  system.defaults.controlcenter = {
    BatteryShowPercentage = true;
  };

  # clock settings
  system.defaults.menuExtraClock = {
    ShowDayOfWeek = true;
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
        NSQuitAlwaysKeepsWindows = false;
        AppleHighlightColor = "0.580000 0.530000 0.620000";
      };
      "com.apple.dock" = {
        wvous-br-corner = 13;
        wvous-br-modifier = 1966080;
        size-immutable = true;
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
        TALLogoutSavesState = false;
        SHOWFULLNAME = true;
      };
      "com.apple.TextEdit" = {
        NSShowAppCentricOpenPanelInsteadOfUntitledFile = false;
      };
    };
  };

  # Inactive time
  power = {
    sleep = {
      computer = 20;
      display = 20;
      allowSleepByPowerButton = true;
    };
  };

  # Mute startup chime
  system.startup.chime = false;

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
      sudo -u "${username}" HOME="$user_home" PATH="/run/current-system/sw/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" "$@"
    }

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

    # Register the apps
    for app in /Applications/Zen.app /Applications/IINA.app /Applications/Zed.app /Applications/MacPacker.app; do
      [ -d "$app" ] && run_as_user /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app" 2>/dev/null || true
    done

    # Default apps
    run_as_user duti ${dutiSettings} 2>/dev/null || true

    run_as_user killall cfprefsd 2>/dev/null || true
  '';
}
