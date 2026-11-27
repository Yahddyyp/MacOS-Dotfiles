{ pkgs, inputs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
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
    ];

    enabledCustomApps = with spicePkgs.apps; [
      marketplace
      {
        src = listeningStatsSrc;
        name = "listening-stats";
      }
    ];

    enabledSnippets = with spicePkgs.snippets; [
      removePopular
      declutterNowPlayingBar
      hideDownloadButton
    ];
  };
}
