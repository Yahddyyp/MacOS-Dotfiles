{ ... }:
{
  programs.ghostty = {
    enable = true;
    package = null;

    settings = {
      theme = "Catppuccin Mocha";

      window-height = 30;
      window-width = 110;
      confirm-close-surface = false;

      font-family = "Maple Mono NF";
      font-family-italic = "Maple Mono NF";
      font-style-italic = "Italic";
      font-size = 12;

      cursor-style = "block";
      cursor-style-blink = true;

      gtk-titlebar = false;
      macos-titlebar-style = "hidden";

      shell-integration-features = "no-cursor";

      window-padding-x = 10;
      window-padding-y = 10;

      term = "xterm-256color";
      macos-option-as-alt = true;
      mouse-hide-while-typing = true;
      adjust-cell-height = "-10%";

      # background-opacity = 0.9;
      # background-blur-radius = 24;
    };
  };
}
