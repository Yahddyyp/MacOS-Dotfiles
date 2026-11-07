{ ... }:
{
  programs.eza = {
    enable = true;
    enableZshIntegration = false;
    enableFishIntegration = false;
    enableNushellIntegration = false;
  };

  catppuccin.eza = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };
}
