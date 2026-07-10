source ~/.cache/zoxide.nu
source ~/.cache/starship/init.nu
source ~/.config/nushell/themes/catppuccin-mocha.nu
source ~/.cache/atuin.nu
source ~/.cache/carapace.nu

# Disable fzf history binding so atuin handles Ctrl+R
$env.FZF_CTRL_R_COMMAND = ""

$env.config = ($env.config | upsert show_banner false)

$env.PATH = (
    $env.PATH
    | prepend "/opt/homebrew/bin"
    | uniq
)

$env.GPG_TTY = (tty)
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")

# Unset LS_COLORS so eza uses its own theme.yml
hide-env -i LS_COLORS

# Add spicetify to PATH
$env.PATH = ($env.PATH | prepend ($env.HOME | path join ".spicetify"))

# Aliases (nushell has no abbr-style expansion, these run as plain aliases)
alias vim = nvim
alias vi = nvim
alias ff = fastfetch
alias oc = opencode
alias cat = bat
alias ls = eza --icons --group-directories-first
alias l = eza --icons --long --group-directories-first --header --git
alias ll = eza --icons --long --group-directories-first --header --git --inode --blocksize
alias la = eza --icons --long --group-directories-first --header --git --inode --blocksize --all
alias lT = eza --icons --tree --group-directories-first --all
alias lt = eza --icons --tree --group-directories-first
alias cd = z 


def tvf [] {
    nvim (tv files)
}

def fix-tmux [] {
    do { ^killall -9 tmux } | ignore
    do { ^pkill -f tmux } | ignore
    rm -rf $"/tmp/tmux-(id -u)"
}

def stop-yabai [] {
    let uid = (id -u | str trim)
    ^launchctl bootout $"gui/($uid)/org.nixos.yabai"
    ^launchctl bootout $"gui/($uid)/org.nixos.skhd"
    ^launchctl bootout $"gui/($uid)/org.nixos.sketchybar"
    ^pkill borders
}

def start-yabai [] {
    let uid = (id -u | str trim)
    for label in [org.nixos.yabai org.nixos.skhd org.nixos.sketchybar] {
        ^launchctl bootout $"gui/($uid)/($label)" | ignore
    }
    for f in [/Library/LaunchAgents/org.nixos.yabai.plist /Library/LaunchAgents/org.nixos.skhd.plist /Library/LaunchAgents/org.nixos.sketchybar.plist] {
        ^launchctl bootstrap $"gui/($uid)" $f | ignore
    }
    bash -c 'borders active_color=0xff74c7ec inactive_color=0xffcba6f7 width=6.0 hidpi=on &'
}

zoxide init nushell | save -f ~/.cache/zoxide.nu

$env.FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude=.git --exclude=Documents --exclude=wallpapers --exclude=Application"

$env.FZF_DEFAULT_OPTS = "--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 --color=selected-bg:#45475A --color=border:#6C7086,label:#CDD6F4"

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

def darwin-rebuild [...args] {
    let user = (whoami)
    let flake_dir = ($env.HOME | path join "dotfiles" "nix")
    sudo /run/current-system/sw/bin/darwin-rebuild ...$args --flake $"path:($flake_dir)#($user)"
}

def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	^yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != $env.PWD and ($cwd | path exists) {
		cd $cwd
	}
	rm -fp $tmp
}

$env.config = ($env.config | upsert edit_mode "vi")

alias gc = git commit -m
alias gca = git commit -a -m
alias gp = git push origin HEAD
alias gpu = git pull origin
alias gst = git status
alias glog = git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit
alias gdiff = git diff
alias gco = git checkout
alias gb = git branch
alias gba = git branch -a
alias gadd = git add
alias ga = git add -p
alias gcoall = git checkout -- .
alias gr = git remote
alias gre = git reset

$env.PROMPT_INDICATOR_VI_NORMAL

$env.PROMPT_INDICATOR_VI_NORMAL = "[N] "
$env.PROMPT_INDICATOR_VI_INSERT = "[I] "

$env.config = ($env.config | upsert completions {
    external: {
        enable: true
        completer: $carapace_completer
    }
})

$env.config = (
    $env.config
    | upsert cursor_shape {
        vi_insert: line
        vi_normal: block
    }
)

