{ ... }:
{
  programs.television = {
    enable = true;
    enableFishIntegration = false;
    enableNushellIntegration = false;
    enableZshIntegration = false;

    settings = {
      tick_rate = 50;
      default_channel = "files";
      history_size = 200;
      global_history = false;

      ui = {
        ui_scale = 100;
        orientation = "landscape";
        theme = "catppuccin";

        input_bar = {
          position = "top";
          prompt = ">";
          border_type = "rounded";
        };

        status_bar = {
          separator_open = "";
          separator_close = "";
          hidden = false;
        };

        results_panel = {
          border_type = "rounded";
        };

        preview_panel = {
          size = 50;
          scrollbar = true;
          border_type = "rounded";
          hidden = false;
        };

        help_panel = {
          show_categories = true;
          hidden = true;
        };

        remote_control = {
          show_channel_descriptions = true;
          sort_alphabetically = true;
        };
      };

      keybindings = {
        esc = "quit";
        ctrl-c = "quit";
        down = "select_next_entry";
        ctrl-n = "select_next_entry";
        ctrl-j = "select_next_entry";
        up = "select_prev_entry";
        ctrl-p = "select_prev_entry";
        ctrl-k = "select_prev_entry";
        ctrl-up = "select_prev_history";
        ctrl-down = "select_next_history";
        tab = "toggle_selection_down";
        backtab = "toggle_selection_up";
        enter = "confirm_selection";
        pagedown = "scroll_preview_half_page_down";
        pageup = "scroll_preview_half_page_up";
        ctrl-f = "cycle_previews";
        ctrl-y = "copy_entry_to_clipboard";
        ctrl-r = "reload_source";
        ctrl-s = "cycle_sources";
        ctrl-t = "toggle_remote_control";
        ctrl-x = "toggle_action_picker";
        ctrl-o = "toggle_preview";
        ctrl-h = "toggle_help";
        f12 = "toggle_status_bar";
        ctrl-l = "toggle_layout";
        backspace = "delete_prev_char";
        ctrl-w = "delete_prev_word";
        ctrl-u = "delete_line";
        delete = "delete_next_char";
        left = "go_to_prev_char";
        right = "go_to_next_char";
        home = "go_to_input_start";
        ctrl-a = "go_to_input_start";
        end = "go_to_input_end";
        ctrl-e = "go_to_input_end";
      };

      shell_integration = {
        fallback_channel = "files";
        channel_triggers = {
          "alias" = [ "alias" "unalias" ];
          "env" = [ "export" "unset" ];
          "dirs" = [ "cd" "ls" "rmdir" "z" ];
          "files" = [
            "cat"
            "less"
            "head"
            "tail"
            "vim"
            "nano"
            "bat"
            "cp"
            "mv"
            "rm"
            "touch"
            "chmod"
            "chown"
            "ln"
            "tar"
            "zip"
            "unzip"
            "gzip"
            "gunzip"
            "xz"
          ];
          "git-diff" = [ "git add" "git restore" ];
          "git-branch" = [
            "git checkout"
            "git switch"
            "git branch"
            "git merge"
            "git rebase"
            "git pull"
            "git push"
          ];
          "git-log" = [ "git log" "git show" ];
          "docker-images" = [ "docker run" ];
          "git-repos" = [ "nvim" "code" "hx" "git clone" ];
        };
        keybindings = {
          smart_autocomplete = "ctrl-t";
          command_history = "ctrl-r";
        };
      };
    };

    channels = {
      alias = {
        metadata = {
          name = "alias";
          description = "A channel to select from shell aliases";
        };
        source = {
          command = "$SHELL -ic 'alias'";
          output = "{split:=:0}";
        };
        preview = {
          command = "$SHELL -ic 'alias' | grep -E '^(alias )?{split:=:0}='";
        };
        ui = {
          preview_panel = {
            size = 30;
          };
        };
      };

      brew-packages = {
        metadata = {
          name = "brew-packages";
          description = "List and manage Homebrew packages";
          requirements = [ "brew" ];
        };
        source = {
          command = [
            "brew list --formula"
            "brew list --cask"
          ];
        };
        preview = {
          command = "brew info '{}'";
        };
        ui = {
          layout = "portrait";
        };
        keybindings = {
          ctrl-u = "actions:upgrade";
          ctrl-d = "actions:uninstall";
        };
        actions = {
          upgrade = {
            description = "Upgrade the selected package";
            command = "brew upgrade '{}'";
            mode = "execute";
          };
          uninstall = {
            description = "Uninstall the selected package";
            command = "brew uninstall '{}'";
            mode = "execute";
          };
        };
      };

      dirs = {
        metadata = {
          name = "dirs";
          description = "A channel to select from directories";
          requirements = [ "fd" ];
        };
        source = {
          command = "fd --type d --hidden --exclude Documents --exclude Public --exclude Music --exclude Movies --exclude Applications --exclude Library --exclude .cache --exclude .local --exclude .oh-my-zsh --exclude .zsh_sessions --exclude .vscode/extensions --exclude .vscode-oss --exclude .DS_Store --exclude .cargo/registry --exclude .ssh --exclude atuin --exclude target/debug --exclude .config/raycast --exclude .git";
        };
        preview = {
          command = "ls -la --color=always '{}'";
        };
        keybindings = {
          shortcut = "f2";
        };
        actions = {
          cd = {
            description = "Open a shell in the selected directory";
            command = "cd '{}' && $SHELL";
            mode = "execute";
          };
          goto_parent_dir = {
            description = "Re-opens tv in the parent directory";
            command = "tv dirs ..";
            mode = "execute";
          };
        };
      };

      files = {
        metadata = {
          name = "files";
          description = "A channel to select files and directories";
          requirements = [ "fd" "bat" ];
        };
        source = {
          command = "fd --type f --type l --hidden --exclude Documents --exclude Public --exclude Music --exclude Movies --exclude Applications --exclude Library --exclude .cache --exclude .local --exclude .oh-my-zsh --exclude .zsh_sessions --exclude .vscode/extensions --exclude .vscode-oss --exclude .DS_Store --exclude .cargo/registry --exclude .ssh --exclude atuin --exclude target/debug --exclude .config/raycast --exclude .git";
        };
        preview = {
          command = "bat -n --color=always '{}'";
          env = {
            BAT_THEME = "ansi";
          };
        };
        keybindings = {
          shortcut = "f1";
          f12 = "actions:edit";
          ctrl-up = "actions:goto_parent_dir";
        };
        actions = {
          edit = {
            description = "Opens the selected entries with the default editor (falls back to vim)";
            command = "\${EDITOR:-vim} '{}'";
            shell = "bash";
            mode = "execute";
          };
          goto_parent_dir = {
            description = "Re-opens tv in the parent directory";
            command = "tv files ..";
            mode = "execute";
          };
        };
      };

      man-pages = {
        metadata = {
          name = "man-pages";
          description = "Browse and preview system manual pages";
          requirements = [ "apropos" "man" ];
        };
        source = {
          command = "apropos .";
        };
        preview = {
          command = "man '{0}'";
          env = {
            MANWIDTH = "80";
          };
        };
        keybindings = {
          enter = "actions:open";
        };
        actions = {
          open = {
            description = "Open the selected man page in the system pager";
            command = "man '{0}'";
            mode = "execute";
          };
        };
        ui = {
          layout = "portrait";
          preview_panel = {
            header = "{0}";
          };
        };
      };

      sesh = {
        metadata = {
          name = "sesh";
          description = "Session manager integrating tmux sessions, zoxide directories, and config paths";
          requirements = [ "sesh" "fd" ];
        };
        source = {
          command = [
            "sesh list --icons"
            "sesh list -t --icons"
            "sesh list -c --icons"
            "sesh list -z --icons"
            "fd -H -d 2 -t d -E .Trash . ~"
          ];
          ansi = true;
          output = "{strip_ansi|split: :1..|join: }";
        };
        preview = {
          command = "sesh preview '{strip_ansi|split: :1..|join: }'";
        };
        keybindings = {
          enter = "actions:connect";
          ctrl-d = [ "actions:kill_session" "reload_source" ];
        };
        actions = {
          connect = {
            description = "Connect to selected session";
            command = "sesh connect '{strip_ansi|split: :1..|join: }'";
            mode = "execute";
          };
          kill_session = {
            description = "Kill selected tmux session (press Ctrl+r to reload)";
            command = "tmux kill-session -t '{strip_ansi|split: :1..|join: }'";
            mode = "fork";
          };
        };
      };

      tmux-windows = {
        metadata = {
          name = "tmux-windows";
          description = "List and switch between tmux windows";
          requirements = [ "tmux" ];
        };
        source = {
          command = "tmux list-windows -a -F '#{session_name}:#{window_index}\t#{window_name}\t#{pane_current_command}'";
          display = "{split:\t:0} - {split:\t:1} ({split:\t:2})";
          output = "{split:\t:0}";
        };
        preview = {
          command = "tmux capture-pane -t '{split:\t:0}' -p 2>/dev/null || echo 'No preview available'";
        };
        actions = {
          select = {
            description = "Switch to the selected window";
            command = "tmux select-window -t '{split:\t:0}'";
            mode = "execute";
          };
          kill = {
            description = "Kill the selected window";
            command = "tmux kill-window -t '{split:\t:0}'";
            mode = "fork";
          };
        };
      };

      zoxide = {
        metadata = {
          name = "zoxide";
          description = "Browse zoxide directory history";
          requirements = [ "zoxide" ];
        };
        source = {
          command = "zoxide query -l";
          no_sort = true;
          frecency = false;
        };
        preview = {
          command = "eza --icons --long --group-directories-first --header --git --inode --blocksize --all";
        };
        keybindings = {
          enter = "actions:cd";
          ctrl-d = "actions:remove";
        };
        actions = {
          cd = {
            description = "Change to the selected directory";
            command = "cd '{}' && $SHELL";
            mode = "execute";
          };
          remove = {
            description = "Remove the selected directory from zoxide";
            command = "zoxide remove '{}'";
            mode = "fork";
          };
        };
      };

      zsh-history = {
        metadata = {
          name = "zsh-history";
          description = "A channel to select from your zsh history";
          requirements = [ "zsh" ];
        };
        source = {
          command = "sed '1!G;h;$!d' \${HISTFILE:-\${HOME}/.zsh_history}";
          display = "{split:;:1..}";
          output = "{split:;:1..}";
          no_sort = true;
          frecency = false;
        };
        actions = {
          execute = {
            description = "Execute the selected command";
            command = "zsh -c '{split:;:1..}'";
            mode = "execute";
          };
        };
      };
    };
  };
}
