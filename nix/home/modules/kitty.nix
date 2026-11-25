{ ... }:
{
  programs.kitty = {
    enable = true;
    package = null;

    font = {
      name = "Maple Mono NF";
      size = 12.0;
    };

    settings = {
      disable_ligatures = "never";
      repaint_delay = 4;
      sync_to_monitor = "yes";
      mouse_hide_wait = -1;
      macos_titlebar_color = "background";
      window_padding_width = 10;
      hide_window_decorations = "titlebar-only";
      background_opacity = 0.9;
      background_blur = 20;
    };
  };

  catppuccin.kitty = {
    enable = true;
    flavor = "mocha";
  };
}
