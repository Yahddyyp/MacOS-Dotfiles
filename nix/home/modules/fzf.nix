{ ... }:
{
  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    historyWidget.command = "";
  };

  catppuccin.fzf = {
    enable = true;
    flavor = "mocha";
  };
}
