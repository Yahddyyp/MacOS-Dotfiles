{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = false;

    settings = builtins.fromTOML (builtins.readFile ../../configs/starship/starship.toml);
  };
}
