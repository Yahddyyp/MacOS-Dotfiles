{ lib, ... }:
{
  programs.nushell = {
    enable = true;
    loadSessionVariables = true;

    settings = {
      show_banner = false;
      edit_mode = "vi";
      cursor_shape = {
        vi_insert = "line";
        vi_normal = "block";
      };
    };

    environmentVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PROMPT_INDICATOR_VI_NORMAL = "[N] ";
      PROMPT_INDICATOR_VI_INSERT = "[I] ";
    };

    extraEnv = ''
      $env.PATH = (
        $env.PATH
        | split row (char esep)
        | prepend "/opt/homebrew/bin"
        | prepend "/opt/homebrew/opt/rustup/bin"
        | prepend ($env.HOME | path join ".cargo" "bin")
        | uniq
      )
    '';

    extraConfig = lib.mkOrder 2500 ''
      # Unset LS_COLORS so eza uses its own theme.yml
      hide-env -i LS_COLORS

      $env.config = (
        $env.config
        | upsert keybindings (
          $env.config.keybindings
          | append [
            {
              name: atuin_up_vi_normal
              modifier: none
              keycode: char_k
              mode: [vi_normal]
              event: {
                send: executehostcommand
                cmd: (_atuin_search_cmd "--shell-up-key-binding")
              }
            }
            {
              name: option_delete_word
              modifier: alt
              keycode: backspace
              mode: [vi_insert, vi_normal]
              event: { edit: BackspaceWord }
            }
            {
              name: clear_whole_line
              modifier: control
              keycode: char_u
              mode: [vi_insert, vi_normal]
              event: [
                { edit: CutFromLineStart }
                { edit: KillLine }
              ]
            }
          ]
        )
      )

      def tvf [] {
        nvim (tv files)
      }

      def fix-tmux [] {
        do { ^killall -9 tmux } | complete
        do { ^pkill -f tmux } | complete
        rm -rf $"/tmp/tmux-(id -u)"
      }

      def stop-yabai [] {
        let uid = (id -u | str trim)
        for label in [org.nixos.yabai org.nixos.skhd org.nixos.sketchybar org.nixos.jankyborders] {
          do { ^launchctl bootout $"gui/($uid)/($label)" } | complete
        }
      }

      def start-yabai [] {
        let uid = (id -u | str trim)
        for label in [org.nixos.yabai org.nixos.skhd org.nixos.sketchybar org.nixos.jankyborders] {
          do { ^launchctl bootout $"gui/($uid)/($label)" } | complete
        }
        for label in [yabai skhd sketchybar jankyborders] {
          for f in [
            $"/Library/LaunchAgents/org.nixos.($label).plist"
            $"($env.HOME)/Library/LaunchAgents/org.nixos.($label).plist"
          ] {
            if ($f | path exists) {
              do { ^launchctl bootstrap $"gui/($uid)" $f } | complete
              break
            }
          }
        }
      }
    '';

    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      ff = "fastfetch";
      cat = "bat";
      cd = "z";
      lT = "eza --icons --tree --group-directories-first --all";
      lt = "eza --icons --tree --group-directories-first";
      l = "eza --icons --long --group-directories-first --header --git";
      ll = "eza --icons --long --group-directories-first --header --git --inode --blocksize";
      la = "eza --icons --long --group-directories-first --header --git --inode --blocksize --all";
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
  };

  catppuccin.nushell = {
    enable = true;
    flavor = "mocha";
  };
}
