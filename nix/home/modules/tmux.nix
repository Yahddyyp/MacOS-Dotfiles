{ pkgs, ... }:
let
  tmuxSimpleRenamers = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-simple-renamers";
    rtpFilePath = "tmux-simple-renamers.tmux";
    version = "unstable-2026-05-10";
    src = pkgs.fetchFromGitHub {
      owner = "yahddyyp";
      repo = "tmux-simple-renamers";
      rev = "f59bbf562bfdfabec18a9e02624bbb86c3bc6e20";
      sha256 = "sha256-CcMYBcwBc/T0UbSk13Z5gba0mqLSurGuwxPODQaEXwQ=";
    };
  };
in
{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_status_background "none"
          set -g @catppuccin_window_text_color "#{E:@thm_surface_0}"
          set -g @catppuccin_window_current_text_color "#{E:@thm_surface_1}"
          set -g @catppuccin_window_status_style "custom"
          set -g @catppuccin_window_current_left_separator "#[bg=default,fg=#{E:@thm_surface_1}]"
          set -g @catppuccin_window_current_right_separator "#[bg=default,fg=#74c7ec]"
          set -g @catppuccin_window_current_middle_separator ""
          set -g @catppuccin_window_left_separator "#[bg=default,fg=#{E:@thm_surface_0}]"
          set -g @catppuccin_window_right_separator "#[bg=default,fg=#fab387]"
          set -g @catppuccin_window_middle_separator ""

          set -g @catppuccin_window_flags "none"
          set -g @catppuccin_window_text "#W "
          set -g @catppuccin_window_current_text "#W#{?window_zoomed_flag, 󰁌,} "
          set -g @catppuccin_window_current_number_color "#74c7ec"
          set -g @catppuccin_session_text " #{s|.*/||:session_name}"
          set -g @catppuccin_window_number_color "#fab387"
          set -g @catppuccin_window_number_position "right"
          set -g @catppuccin_directory_color "#cba6f7"
          set -g @catppuccin_status_directory_icon_fg "#11111b"
          set -g @catppuccin_directory_text " #{?#{==:#{pane_current_path},$HOME},~,#{b:pane_current_path}}"

          set -g @catppuccin_status_left_separator  " "
          set -g @catppuccin_status_right_separator ""
          set -g @catppuccin_status_fill "icon"
          set -g @catppuccin_status_connect_separator "no"
        '';
      }
      yank
      tmux-fzf
      {
        plugin = tmux-floax;
        extraConfig = ''
          set -g @floax-bind 'g'
          set -g @floax-width '80%'
          set -g @floax-height '80%'
          set -g @floax-border-color '#cba6f7'
          set -g @floax-text-color '#cdd6f4'
          set -g @floax-change-path 'true'
        '';
      }
      {
        plugin = tmuxSimpleRenamers;
        extraConfig = ''
          set -g @tmux-simple-renamers-sesh-integration 'on'
          set -g @tmux-simple-renamers-start-blank "on"
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.local/share/tmux/resurrect'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];

    extraConfig = ''
      # General
      set -g set-clipboard on
      set -g status-position top
      set -g set-titles-string "#S:#I.#P"
      set -g allow-rename off
      set -g automatic-rename on
      set -g renumber-windows on
      setw -g pane-base-index 1

      # Key bindings
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."
      bind-key x kill-pane
      bind-key Q confirm-before -p "Kill tmux server? (y/n)" kill-server
      bind-key m split-window -v
      bind-key u split-window -h
      bind-key Tab last-window
      unbind l

      # Sesh integration
      bind -N "last-session (via sesh)" j run-shell "sesh last"

      # Smart pane switching with awareness of Vim and Atuin
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf|atuin|tv)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R

      bind C-l send-keys 'C-l'

      # Status bar layout
      set -g status 2
      set -g status-format[1] ""
      set -g status-justify left
      set -g status-right-length 100
      set -g status-left-length 100

      set -g status-left "#{E:@catppuccin_status_session} "
      set -g status-right "#{E:@catppuccin_status_directory}"

      set -g status-bg default
      set -g status-style bg=default
      set -g window-status-current-style "none"
    '';
  };
}
