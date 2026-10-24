{ ... }:
{
  programs.atuin = {
    enable = true;

    settings = {
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "global";
      search_mode_shell_up_key_binding = "fuzzy";
      workspaces = true;
      style = "compact";
      show_preview = true;
      max_preview_height = 4;
      show_help = true;
      show_tabs = true;
      auto_hide_height = 8;
      enter_accept = true;
      command_chaining = true;
      show_numeric_shortcuts = true;
      inline_height = 0;
      keymap_mode = "vim-normal";
      keymap_cursor = {
        emacs = "blink-block";
        vim_insert = "blink-bar";
        vim_normal = "steady-block";
      };
      dialect = "uk";
      timezone = "local";
      secrets_filter = true;
      exit_mode = "return-original";
      history_format = "{time}\t{command}\t{duration}";
      sync_frequency = "0";
      auto_sync = true;
      update_check = true;
      network_connect_timeout = 5;
      network_timeout = 5;
      local_timeout = 5;

      history_filter = [
        "^secret-cmd"
        "^export\\s+(AWS_|GITHUB_|STRIPE_|OPENAI_|ANTHROPIC_|GEMINI_|API_|SECRET_|TOKEN_|PASS_)"
        "^ssh-add\\s"
        "password"
        "token"
        "secret"
        "bearer"
        "api[_-]?key"
        "gh\\s+auth\\s+login"
        "pass\\s+(show|insert|generate)"
        "gpg\\s+--import"
        "^source\\s+.*\\.env"
        "^ls(\\s|$)"
        "^la(\\s|$)"
        "^ll(\\s|$)"
        "^l(\\s|$)"
        "^lt(\\s|$)"
        "^lT(\\s|$)"
        "^cd(\\s|$)"
        "^z(\\s|$)"
        "^pwd$"
        "^clear$"
        "^exit$"
        "^y(\\s|$)"
        "^ff$"
      ];

      search = {
        filters = [ "global" "host" "session" "workspace" "directory" ];
      };

      ui = {
        columns = [ "duration" "time" "command" ];
      };

      preview = {
        strategy = "auto";
      };

      keys = {
        scroll_exits = true;
        "ctrl-j" = "history_list_next";
        "ctrl-k" = "history_list_prev";
      };

      stats = {
        common_subcommands = [
          "aerospace"
          "brew"
          "bun"
          "cargo"
          "darwin-rebuild"
          "docker"
          "gh"
          "git"
          "go"
          "home-manager"
          "just"
          "kubectl"
          "launchctl"
          "nix"
          "npm"
          "npx"
          "pass"
          "pnpm"
          "podman"
          "sesh"
          "skhd"
          "spicetify"
          "tailscale"
          "tmux"
          "yabai"
          "yarn"
        ];
        common_prefix = [ "sudo" ];
        ignored_commands = [
          "cd"
          "clear"
          "exit"
          "ff"
          "l"
          "la"
          "ll"
          "ls"
          "lt"
          "lT"
          "pwd"
          "y"
          "z"
        ];
      };

      sync = {
        records = true;
      };

      daemon = {
        enabled = true;
        autostart = true;
      };

      tmux = {
        enabled = true;
        width = "90%";
        height = "75%";
      };

      ai = {
        enabled = false;
      };
    };
  };

  catppuccin.atuin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };
}
