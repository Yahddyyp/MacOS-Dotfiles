{ config, ... }:
{
  programs.gh.gitCredentialHelper.enable = false;

  home.file.".gitconfig".text = ''
    [core]
    	editor = nvim
    	pager = hunk pager
    [credential]
    	helper = osxkeychain
    [credential "https://github.com"]
    	helper =
    	helper = ${config.programs.gh.package}/bin/gh auth git-credential
    [credential "https://gist.github.com"]
    	helper =
    	helper = ${config.programs.gh.package}/bin/gh auth git-credential
    [user]
    	name = Yahddyyp
    	email = Yahddyyp@gmail.com
    [interactive]
    	diffFilter = delta --color-only
    [delta]
    	navigate = true
    	line-numbers = true
    	features = catppuccin-mocha
    [include]
    	path = ~/.config/lazygit/catppuccin-mocha-delta.gitconfig
  '';
}
