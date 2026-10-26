{ ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        diffRenderers = [
          {
            colorArg = "always";
            command = "delta --dark --paging=never";
          }
        ];
      };
    };
  };

  catppuccin.lazygit = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };
}
