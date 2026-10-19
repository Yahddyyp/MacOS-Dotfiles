{ config, ... }:
{
  programs.gh.gitCredentialHelper.enable = false;

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Yahddyyp";
        email = "Yahddyyp@gmail.com";
      };

      core = {
        editor = "nvim";
        pager = "hunk pager";
      };

      interactive.diffFilter = "delta --color-only";

      delta = {
        navigate = true;
        line-numbers = true;
        features = "catppuccin-mocha";
      };

      credential.helper = "osxkeychain";

      credential."https://github.com".helper = [
        ""
        "${config.programs.gh.package}/bin/gh auth git-credential"
      ];

      credential."https://gist.github.com".helper = [
        ""
        "${config.programs.gh.package}/bin/gh auth git-credential"
      ];
    };

    includes = [
      {
        path = "~/.config/lazygit/catppuccin-mocha-delta.gitconfig";
      }
    ];
  };
}
