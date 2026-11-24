{ pkgs, spicetify-nix, ... }:
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  listeningStatsSrc = pkgs.fetchzip {
    url = "https://github.com/Xndr2/listening-stats/releases/download/v3.1/listening-stats.zip";
    hash = "sha256-NLe9bkD6Xhft1yG+YE69ZMZ789IHam36AvXt9tMMf68=";
    stripRoot = false;
  };
in
{
  programs.spicetify = {
    enable = true;

    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with spicePkgs.extensions; [
      keyboardShortcut
      shuffle
      trashbin
      adblock
      spicyLyrics
      ({
        src = "${pkgs.fetchFromGitHub {
          owner = "wSoltani";
          repo = "syncify";
          rev = "v1.16.0";
          hash = "sha256-50vZFyQbCKIZSJbFYuBB3O/DNS5djZQSJoqv/NvEq4c=";
        }}/dist";
        name = "syncify.js";
      })
    ];

    enabledCustomApps = with spicePkgs.apps; [
      marketplace
      ({
        src = listeningStatsSrc;
        name = "listening-stats";
      })
    ];

    enabledSnippets = (with spicePkgs.snippets; [
      removePopular
      declutterNowPlayingBar
    ]) ++ [
      ''
        *,
        *::before,
        *::after {
          backdrop-filter: none !important;
          -webkit-backdrop-filter: none !important;
          transition: none !important;
          box-shadow: none !important;
        }

        .under-main-view,
        [class*="background"],
        [class*="blur"] {
          filter: none !important;
          -webkit-filter: none !important;
        }

        .Root__top-container,
        .Root__main-view,
        .Root__nav-bar,
        .Root__right-sidebar {
          contain: layout style !important;
        }
      ''
    ];
  };
}
