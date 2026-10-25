{ ... }:
{
  programs.kitty = {
    enable = true;
    package = null;
    shellIntegration.enableZshIntegration = false;

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
      # hide_window_decorations = true;
      # background_opacity = 0.9;
    };
  };

  catppuccin.kitty = {
    enable = true;
    flavor = "mocha";
  };
}
