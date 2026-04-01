if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

set -gx EDITOR nvim
set -gx VISUAL nvim

fish_add_path $HOME/.spicetify

abbr --add vim nvim
abbr --add vi nvim
abbr --add ff 'nvim $(fzf -m --preview="bat --color=always {}")'
abbr --add cd z

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
    atuin init fish | source
end
