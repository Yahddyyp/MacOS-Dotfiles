{ ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
      save_config_on_exit = false;
    };
  };

  catppuccin.btop = {
    enable = true;
    flavor = "mocha";
  };
}
