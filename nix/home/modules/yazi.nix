{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";

    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar;
    };

    settings = {
      mgr = {
        show_hidden = true;
      };
    };

    plugins = {
      starship = pkgs.yaziPlugins.starship;
    };

    initLua = ''
      require("starship"):setup({
        hide_flags = false,
        flags_after_prompt = true,
        show_right_prompt = false,
        hide_count = false,
        count_separator = " ",
      })
    '';

    extraPackages = with pkgs; [
      file
      poppler
      resvg
    ];
  };

  catppuccin.yazi = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };
}
