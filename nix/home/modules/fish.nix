{ ... }:
{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      vim = "nvim";
      vi = "nvim";
      ff = "fastfetch";
      tvf = "nvim (tv files)";
      cd = "z";
      ls = "eza --icons --group-directories-first";
      l = "eza --icons --long --group-directories-first --header --git";
      ll = "eza --icons --long --group-directories-first --header --git --inode --blocksize";
      la = "eza --icons --long --group-directories-first --header --git --inode --blocksize --all";
      lT = "eza --icons --tree --group-directories-first --all";
      lt = "eza --icons --tree --group-directories-first";
      fix-tmux = "killall -9 tmux; pkill -f tmux; rm -rf /tmp/tmux-(id -u)";
      cat = "bat";
      gc = "git commit -m";
      gca = "git commit -a -m";
      gp = "git push origin HEAD";
      gpu = "git pull origin";
      gst = "git status";
      glog = "git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit";
      gdiff = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gba = "git branch -a";
      gadd = "git add";
      ga = "git add -p";
      gcoall = "git checkout -- .";
      gr = "git remote";
      gre = "git reset";
    };

    functions = {
      stop-yabai = ''
        set uid (id -u)
        launchctl bootout "gui/$uid/org.nixos.yabai" 2>/dev/null
        launchctl bootout "gui/$uid/org.nixos.skhd" 2>/dev/null
        launchctl bootout "gui/$uid/org.nixos.sketchybar" 2>/dev/null
        launchctl bootout "gui/$uid/org.nixos.jankyborders" 2>/dev/null
      '';
      start-yabai = ''
        set uid (id -u)
        for label in org.nixos.{yabai,skhd,sketchybar,jankyborders}
            launchctl bootout "gui/$uid/$label" 2>/dev/null
        end
        for f in /Library/LaunchAgents/org.nixos.{yabai,skhd,sketchybar}.plist "$HOME/Library/LaunchAgents/org.nixos.jankyborders.plist"
            launchctl bootstrap "gui/$uid" "$f" 2>/dev/null
        end
      '';
    };

    interactiveShellInit = ''
      # Homebrew PATH
      fish_add_path /opt/homebrew/bin

      # Environment
      set -x GPG_TTY (tty)
      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -e LS_COLORS
      set -gx EZA_CONFIG_DIR "$HOME/.config/eza"

      # Starship prompt
      starship init fish | source

      # Vi keybindings
      set -g fish_key_bindings fish_vi_key_bindings

      # Atuin vi normal mode binding
      bind -M default k _atuin_bind_up

      # External environment files if present
      test -f "$HOME/.local/bin/env.fish"; and source "$HOME/.local/bin/env.fish"
      test -f "$HOME/.cargo/env.fish"; and source "$HOME/.cargo/env.fish"
    '';
  };

  catppuccin.fish = {
    enable = true;
    flavor = "mocha";
  };
}
