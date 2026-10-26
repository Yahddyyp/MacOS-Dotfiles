{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      ff = "fastfetch";
      tvf = "nvim $(tv files)";
      cd = "z";
      ls = "eza --icons --group-directories-first";
      l = "eza --icons --long --group-directories-first --header --git";
      ll = "eza --icons --long --group-directories-first --header --git --inode --blocksize";
      la = "eza --icons --long --group-directories-first --header --git --inode --blocksize --all";
      lT = "eza --icons --tree --group-directories-first --all";
      lt = "eza --icons --tree --group-directories-first";
      fix-tmux = "killall -9 tmux; pkill -f tmux; rm -rf /tmp/tmux-$(id -u)";
      stop-yabai = "launchctl bootout \"gui/$UID/org.nixos.yabai\" 2>/dev/null; launchctl bootout \"gui/$UID/org.nixos.skhd\" 2>/dev/null; launchctl bootout \"gui/$UID/org.nixos.sketchybar\" 2>/dev/null; launchctl bootout \"gui/$UID/org.nixos.jankyborders\" 2>/dev/null";
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

    sessionVariables = {
      PASSWORD_STORE_EXTENSIONS_DIR = "$HOME/.local/share/pass-extensions";
      PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
      GPG_TTY = "$TTY";
      EDITOR = "nvim";
      VISUAL = "nvim";
      ZVM_INIT_MODE = "sourcing";
    };

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Powerlevel10k instant prompt (must be at the very top of ~/.zshrc)
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      (lib.mkOrder 901 ''
        # Powerlevel10k theme configuration (must be sourced immediately after the theme plugin)
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '')

      (lib.mkAfter ''
        # Carapace completions
        source <(carapace _carapace zsh)

        # Homebrew PATH
        if [ -x /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        # Rustup
        if [ -d /opt/homebrew/opt/rustup/bin ]; then
          export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
        fi

        # Unset LS_COLORS so eza uses its own theme.yml
        unset LS_COLORS
        export EZA_CONFIG_DIR="$HOME/.config/eza"

        # Atuin keybindings
        bindkey -M emacs '^R' atuin-search
        bindkey -M viins '^R' atuin-search-viins
        bindkey -M vicmd '^R' atuin-search-vicmd

        # Service helpers
        function start-yabai() {
          for label in org.nixos.{yabai,skhd,sketchybar,jankyborders}; do
            launchctl bootout "gui/$UID/$label" 2>/dev/null
          done
          for label in {yabai,skhd,sketchybar,jankyborders}; do
            for f in "/Library/LaunchAgents/org.nixos.$label.plist" "$HOME/Library/LaunchAgents/org.nixos.$label.plist"; do
              if [ -f "$f" ]; then
                launchctl bootstrap "gui/$UID" "$f" 2>/dev/null
                break
              fi
            done
          done
        }
      '')
    ];
  };

  catppuccin.zsh-syntax-highlighting = {
    enable = true;
    flavor = "mocha";
  };
}
