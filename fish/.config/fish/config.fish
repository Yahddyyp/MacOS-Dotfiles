# Homebrew PATH (must be before any Homebrew-installed tools)
fish_add_path /opt/homebrew/bin

if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx XDG_CONFIG_HOME "$HOME/.config"

fish_add_path $HOME/.spicetify

abbr --add vim nvim
abbr --add vi nvim
abbr --add ff 'nvim $(fzf -m --preview="bat --color=always {}")'
abbr --add cd z
abbr --add fix-tmux 'killall -9 tmux; pkill -f tmux; rm -rf /tmp/tmux-$(id -u)'

set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude=.git --exclude=Documents --exclude=wallpapers --exclude=Application'

set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

fzf --fish | source

zoxide init fish | source

if status is-interactive
    set -gx ATUIN_CONFIG_DIR "$HOME/.config/atuin"
    atuin init fish | source

    # Bind 'k' in vi normal mode to atuin history search
    bind -M default k _atuin_bind_up
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

set -g fish_key_bindings fish_vi_key_bindings
