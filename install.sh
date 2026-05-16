#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d)"
PACKAGES=("zsh" "nvim" "tmux" "fish" "kitty" "ghostty" "starship" "sketchybar" "yabai" "skhd" "zed" "atuin" "btop" "yazi" "neofetch" "p10k" "home" "bat" "lazygit" "sesh" "gh-dash" "aerospace" "borders" "television" "opencode" "eza")

info() { echo "[info] $1"; }
ok() { echo "[ok] $1"; }
warn() { echo "[warn] $1"; }
err()  { echo "[error] $1"; }

phase_clone() {
  if [ -d "$DOTFILES_DIR/.git" ]; then
    info "dotfiles already cloned, pulling latest changes..."
    cd "$DOTFILES_DIR"
    git pull --rebase --autostash
    ok "dotfiles up to date"
  else
    info "cloning dotfiles repo..."
    git clone https://github.com/Yahddyyp/MacOS-Dotfiles "$DOTFILES_DIR"
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
     ".config/bat"
     ".config/lazygit"
     ".config/sesh"
     ".config/gh-dash"
     ".config/aerospace"
     ".config/borders"
     ".config/television"
     ".config/opencode"
     ".config/eza"
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
    err "Brewfile not found at $DOTFILES_DIR/Brewfile"
    exit 1
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
      stow --restow --no-folding --verbose --target="$HOME" "$pkg"
      ok "stowed: $pkg"
    else
      warn "skipping missing package: $pkg"
    fi
  done

  ok "all dotfiles linked"
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
    curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh 2>/dev/null || true
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

  info "removing dock autohide delay..."
  defaults write com.apple.dock autohide-delay -float 0
  killall Dock || true
  ok "dock autohide delay removed"

  info "moving dock to the right..."
  defaults write com.apple.dock orientation -string right
  killall Dock || true
  ok "dock moved to the right"

  info "disabling VSCodium press-and-hold..."
  defaults write com.visualstudio.code.oss ApplePressAndHoldEnabled -bool false
  ok "VSCodium press-and-hold disabled"
}

print_summary() {
  echo ""
  echo "done."
  echo ""
  echo "next steps:"
  echo "  - restart your terminal"
  echo "  - open a new tmux session and press prefix + I to install tpm plugins"
  echo "  - run: spicetify apply (after opening spotify once)"
  echo "  - start sketchybar: brew services start sketchybar"
  echo "  - start yabai: yabai --start-service"
  echo "  - start skhd: skhd --start-service"
  echo ""
}

main() {
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
  phase_post_install
  echo ""
  print_summary
}

main
