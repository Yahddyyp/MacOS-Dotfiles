#ZSH_THEME
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git zsh-autosuggestions zsh-vi-mode)

source $ZSH/oh-my-zsh.sh

# Unset LS_COLORS so eza uses its own theme.yml
unset LS_COLORS


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export PATH=$PATH:$HOME/.spicetify

alias vim='nvim'
alias vi='nvim'
alias ff='nvim $(fzf -m --preview="bat --color=always {}")'
alias tvf='nvim $(tv files)'
alias cd="z"
alias ls="eza --icons --group-directories-first"
alias l="eza --icons --long --group-directories-first --header --git"
alias ll="eza --icons --long --group-directories-first --header --git --inode --blocksize"
alias la="eza --icons --long --group-directories-first --header --git --inode --blocksize --all"
alias lt="eza --icons --tree --group-directories-first"
alias fix-tmux="killall -9 tmux; pkill -f tmux; rm -rf /tmp/tmux-$(id -u)"
alias stop-yabai='yabai --stop-service && skhd --stop-service && brew services stop sketchybar'
alias start-yabai='yabai --start-service && skhd --start-service && brew services start sketchybar'

alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'


export EDITOR='nvim'
export VISUAL='nvim'
export XDG_CONFIG_HOME="$HOME/.config"

# eza config directory
export EZA_CONFIG_DIR="$HOME/.config/eza"

#fzf
source <(fzf --zsh)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude=.git --exclude=Documents --exclude=wallpapers --exclude=Application '

eval "$(zoxide init zsh)"

# Atuin setup using Homebrew binary and dotfile config
export ATUIN_CONFIG_DIR="$HOME/.config/atuin"
eval "$(atuin init zsh)"

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh


# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
