{ ... }:
{
  programs.sesh = {
    enable = true;
    enableAlias = false;
    enableTmuxIntegration = false;

    settings = {
      blacklist = [ "scratch" ];
      default_session = {
        dir_length = 1;
      };
    };
  };
}
