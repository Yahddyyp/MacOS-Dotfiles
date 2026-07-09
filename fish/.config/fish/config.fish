# Homebrew PATH (must be before any Homebrew-installed tools)
fish_add_path /opt/homebrew/bin

fish_config theme choose catppuccin-mocha --color-theme=dark

if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

set -x GPG_TTY (tty)

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx XDG_CONFIG_HOME "$HOME/.config"

# Unset LS_COLORS so eza uses its own theme.yml
set -e LS_COLORS

fish_add_path $HOME/.spicetify

abbr --add vim nvim
abbr --add vi nvim
abbr --add ff fastfetch
abbr --add tvf 'nvim (tv files)'
abbr --add cd z
abbr --add ls "eza --icons --group-directories-first"
abbr --add l "eza --icons --long --group-directories-first --header --git"
abbr --add ll "eza --icons --long --group-directories-first --header --git --inode --blocksize"
abbr --add la "eza --icons --long --group-directories-first --header --git --inode --blocksize --all"
abbr --add lT "eza --icons --tree --group-directories-first --all"
abbr --add lt "eza --icons --tree --group-directories-first"
abbr --add fix-tmux 'killall -9 tmux; pkill -f tmux; rm -rf /tmp/tmux-$(id -u)'
function stop-yabai
  set uid (id -u)
  launchctl bootout "gui/$uid/org.nixos.yabai" 2>/dev/null
  launchctl bootout "gui/$uid/org.nixos.skhd" 2>/dev/null
  launchctl bootout "gui/$uid/org.nixos.sketchybar" 2>/dev/null
  pkill borders 2>/dev/null
end
function start-yabai
  set uid (id -u)
  for f in ~/Library/LaunchAgents/org.nixos.{yabai,skhd,sketchybar}.plist
    launchctl bootstrap "gui/$uid" "$f" 2>/dev/null
  end
  borders active_color=0xff74c7ec inactive_color=0xffcba6f7 width=6.0 hidpi=on &
end
abbr --add oc opencode
abbr --add cat bat

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

function darwin-rebuild
    set user (whoami)
    set flake_dir "$HOME/dotfiles/nix"
    sudo /run/current-system/sw/bin/darwin-rebuild $argv --flake "path:$flake_dir#$user"
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

abbr --add gc "git commit -m"
abbr --add gca "git commit -a -m"
abbr --add gp "git push origin HEAD"
abbr --add gpu "git pull origin"
abbr --add gst "git status"
abbr --add glog "git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
abbr --add gdiff "git diff"
abbr --add gco "git checkout"
abbr --add gb "git branch"
abbr --add gba "git branch -a"
abbr --add gadd "git add"
abbr --add ga "git add -p"
abbr --add gcoall "git checkout -- ."
abbr --add gr "git remote"
abbr --add gre "git reset"
