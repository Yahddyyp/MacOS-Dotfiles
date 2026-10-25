{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

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
  };

  catppuccin.yazi = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };
}
