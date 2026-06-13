#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d)"
PACKAGES=("zsh" "nvim" "tmux" "fish" "kitty" "ghostty" "starship" "sketchybar" "yabai" "skhd" "zed" "atuin" "btop" "yazi" "neofetch" "fastfetch" "p10k" "home" "bat" "lazygit" "sesh" "gh-dash" "aerospace" "borders" "television" "opencode" "eza" "ohmyzsh")

info() { echo "[info] $1"; }
ok() { echo "[ok] $1"; }
warn() { echo "[warn] $1"; }
err() { echo "[error] $1"; }

phase_clone() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    info "dotfiles already cloned, pulling..."
    cd "$DOTFILES_DIR"
    git pull --rebase --autostash
  elif [ -d "$DOTFILES_DIR" ]; then
    mv "$DOTFILES_DIR" "$DOTFILES_DIR-backup-$(date +%Y%m%d)"
    git clone https://github.com/Yahddyyp/MacOS-Dotfiles.git "$DOTFILES_DIR"
  else
    info "cloning dotfiles repo..."
    git clone https://github.com/Yahddyyp/MacOS-Dotfiles.git "$DOTFILES_DIR"
    ok "dotfiles cloned"
  fi
}

phase_prerequisites() {
  info "checking prerequisites..."

  if ! command -v brew &>/dev/null; then
    warn "homebrew not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
    export PATH="/opt/homebrew/bin:$PATH"
    ok "homebrew installed"
  else
    ok "homebrew found"
  fi

  if ! command -v stow &>/dev/null; then
    info "installing gnu stow..."
    /opt/homebrew/bin/brew install stow
    ok "stow installed"
  else
    ok "stow found"
  fi

  if ! command -v git &>/dev/null; then
    info "installing git..."
    /opt/homebrew/bin/brew install git
    ok "git installed"
  else
    ok "git found"
  fi
}

phase_ohmyzsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "oh-my-zsh already installed"
  else
    info "installing oh-my-zsh..."
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ok "oh-my-zsh installed"
  fi
}

phase_backup() {
  info "checking for existing dotfiles to backup..."

  local targets=(
    ".zshrc"
    ".tmux.conf"
    ".p10k.zsh"
    ".hushlogin"
    ".config/fish"
    ".config/nvim"
    ".config/kitty"
    ".config/ghostty"
    ".config/starship.toml"
    ".config/sketchybar"
    ".config/yabai"
    ".config/skhd"
    ".config/zed"
    ".config/atuin"
    ".config/btop"
    ".config/spicetify"
    ".config/yazi"
    ".config/neofetch"
    ".config/fastfetch"
    ".config/bat"
    ".config/lazygit"
    ".config/sesh"
    ".config/gh-dash"
    ".config/aerospace"
    ".config/borders"
    ".config/television"
    ".config/opencode"
    ".config/eza"
    ".oh-my-zsh/custom/plugins"
    ".gitconfig"
  )

  local found=0
  for target in "${targets[@]}"; do
    if [ -L "$HOME/$target" ]; then
      local link_target
      link_target="$(readlink "$HOME/$target")"
      if [[ "$link_target" == *"$DOTFILES_DIR"* ]]; then
        continue
      fi
    fi
    if [ -e "$HOME/$target" ] || [ -L "$HOME/$target" ]; then
      if [ $found -eq 0 ]; then
        mkdir -p "$BACKUP_DIR"
        info "backing up to $BACKUP_DIR"
      fi
      found=1
      local backup_target="$BACKUP_DIR/$target"
      mkdir -p "$(dirname "$backup_target")"
      mv "$HOME/$target" "$backup_target"
      warn "backed up: $target"
    fi
  done

  if [ $found -eq 0 ]; then
    ok "nothing to backup"
  else
    ok "backup complete"
  fi
}

phase_brew_bundle() {
  info "installing tools via homebrew bundle..."
  if [ ! -f "$DOTFILES_DIR/Brewfile" ]; then
    warn "Brewfile not found at $DOTFILES_DIR/Brewfile, skipping."
    return
  fi
  /opt/homebrew/bin/brew bundle install --file="$DOTFILES_DIR/Brewfile" --no-lock || warn "some packages may have failed to install"
  ok "all tools installed"
}

phase_stow() {
  mkdir -p "$HOME/.config"
  info "linking dotfiles with stow..."

  cd "$DOTFILES_DIR"
  for pkg in "${PACKAGES[@]}"; do
    if [ -d "$pkg" ]; then
      if [ "$pkg" = "zsh" ] && [ -f "$HOME/.zshrc" ] && ! [ -L "$HOME/.zshrc" ]; then
        info "removing oh-my-zsh generated .zshrc before stowing..."
        rm "$HOME/.zshrc"
      fi
      local stow_err
      stow_err="$(mktemp)"
      if ! stow --restow --no-folding --target="$HOME" "$pkg" 2>"$stow_err"; then
        warn "stow failed for $pkg: $(cat "$stow_err")"
      else
        ok "stowed: $pkg"
      fi
      rm -f "$stow_err"
    else
      warn "skipping missing package: $pkg"
    fi
  done

  ok "all dotfiles linked"
}

phase_git_config() {
  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.line-numbers true
  git config --global delta.features "catppuccin-mocha"
  git config --global include.path "$HOME/.config/lazygit/catppuccin-mocha-delta.gitconfig"
  ok "delta configured in .gitconfig"

  if git config user.name &>/dev/null && git config user.email &>/dev/null; then
    ok "git user config found"
    return
  fi

  local backup_file=""
  for dir in "$HOME"/dotfiles-backup-*; do
    if [ -f "$dir/.gitconfig" ]; then
      backup_file="$dir/.gitconfig"
      break
    fi
  done

  if [ -n "$backup_file" ]; then
    local git_name git_email
    git_name=$(grep -A2 '\[user\]' "$backup_file" 2>/dev/null | grep 'name' | sed 's/.*= *//')
    git_email=$(grep -A2 '\[user\]' "$backup_file" 2>/dev/null | grep 'email' | sed 's/.*= *//')
    if [ -n "$git_name" ]; then
      git config --global user.name "$git_name"
    fi
    if [ -n "$git_email" ]; then
      git config --global user.email "$git_email"
    fi
    ok "restored git user from backup"
  else
    warn "git user.name and user.email not set - git will prompt you on first commit"
  fi
}

phase_post_install() {
  info "running post-install tasks..."

  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    info "initializing tpm plugins..."
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
    ok "tpm plugins initialized"
  fi

  if command -v spicetify &>/dev/null; then
    info "installing spicetify marketplace..."
    curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh
    ok "spicetify marketplace installed"

    info "applying spicetify..."
    spicetify backup apply 2>/dev/null || true
    ok "spicetify applied"
  fi

  if command -v bat &>/dev/null; then
    info "rebuilding bat theme cache..."
    bat cache --build 2>/dev/null || true
    ok "bat cache rebuilt"
  fi

  if command -v gh &>/dev/null; then
    info "installing gh-dash extension..."
    gh extension install --force dlvhdr/gh-dash 2>/dev/null || true
    ok "gh-dash extension installed"
  fi

  if command -v pass &>/dev/null && [ ! -f "/opt/homebrew/lib/password-store/extensions/update.bash" ]; then
    info "installing pass-update extension..."
    git clone https://github.com/roddhjav/pass-update.git /tmp/pass-update
    cd /tmp/pass-update && sudo make install
    rm -rf /tmp/pass-update
    ok "pass-update installed"
  elif [ -f "/opt/homebrew/lib/password-store/extensions/update.bash" ]; then
    ok "pass-update already installed"
  fi

  if command -v pinentry-mac &>/dev/null && ! grep -q "pinentry-program" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    info "configuring pinentry-mac for GPG..."
    echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> "$HOME/.gnupg/gpg-agent.conf"
    gpgconf --reload gpg-agent 2>/dev/null || true
    ok "pinentry-mac configured"
  elif grep -q "pinentry-program" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    ok "pinentry-mac already configured"
  fi

  info "removing dock autohide delay..."
  defaults write com.apple.dock autohide-delay -float 0
  info "moving dock to the right..."
  defaults write com.apple.dock orientation -string right
  killall Dock || true
  ok "dock autohide delay removed"
  ok "dock moved to the right"

  info "setting up yabai scripting addition LaunchDaemon..."
  sudo -v || { err "sudo authentication failed"; return 1; }
  sudo cp "$DOTFILES_DIR/yabai/.config/yabai/com.asmvik.yabai-sa.plist" /Library/LaunchDaemons/com.asmvik.yabai-sa.plist
  sudo launchctl unload /Library/LaunchDaemons/com.asmvik.yabai-sa.plist 2>/dev/null || true
  sudo launchctl load -w /Library/LaunchDaemons/com.asmvik.yabai-sa.plist
  ok "yabai scripting addition LaunchDaemon installed"
}

print_summary() {
  echo ""
  echo "done."
  echo ""
  echo "next steps:"
  echo "  1. If not done already, disable SIP and set the nvram boot-arg (see README)"
  echo "  2. Restart your terminal"
  echo "  3. Load the scripting addon now (the LaunchDaemon will load it automatically on future boots): sudo yabai --load-sa"
  echo "  4. Open a new tmux session and press prefix + I to install tpm plugins"
  echo "  5. Run: spicetify apply (after opening spotify once)"
  echo "  6. Start services:"
  echo "     - sketchybar: brew services start sketchybar"
  echo "     - yabai: yabai --start-service"
  echo "     - skhd: skhd --start-service"
  echo ""
}

main() {
  info "this script requires sudo access for some steps (yabai, LaunchDaemon, etc.)"
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

  phase_prerequisites
  echo ""
  phase_clone
  echo ""
  phase_ohmyzsh
  echo ""
  phase_backup
  echo ""
  phase_brew_bundle
  echo ""
  phase_stow
  echo ""
  phase_git_config
  echo ""
  phase_post_install
  echo ""
  print_summary
}

main
