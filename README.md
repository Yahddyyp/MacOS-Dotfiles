# MacOS Dotfiles

![Full Setup](Images/Desktop.jpeg)

## Tools and apps I use:

### Window Management
- **[yabai](https://github.com/koekeishiya/yabai)** — Tiling window manager
- **[skhd](https://github.com/koekeishiya/skhd)** — Hotkey daemon
- **[JankyBorders](https://github.com/FelixKratz/JankyBorders)** — Window border highlighting

### Status Bar
- **[sketchybar](https://github.com/FelixKratz/sketchybar)** — Highly customizable macOS status bar replacement

### Terminal
- **[zsh](https://zsh.org/)** + **[oh-my-zsh](https://ohmyz.sh/)** + **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** — Shell framework & prompt theme
- **[fish](https://fishshell.com/)** — Alternative user-friendly shell
- **[starship](https://starship.rs/)** — Cross-shell prompt
- **[kitty](https://sw.kovidgoyal.net/kitty/)** / **[ghostty](https://ghostty.org/)** — GPU-accelerated terminals
- **[tmux](https://github.com/tmux/tmux)** — Terminal multiplexer

### CLI Tools
| Tool | Purpose |
|------|---------|
| [neovim](https://neovim.io/) | TUI-based Text editor |
| [yazi](https://yazi-rs.github.io/) | Terminal file manager |
| [btop](https://github.com/aristocratos/btop) | System monitor |
| [atuin](https://atuin.sh/) | Shell history replacement |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast `grep` alternative |
| [fd](https://github.com/sharkdp/fd) | Fast `find` alternative |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |
| [sesh](https://github.com/joshmedeski/sesh) | terminal session manager |
| [gh-dash](https://github.com/dlvhdr/gh-dash) | Beautiful CLI dashboard for GitHub |
| [gh](https://cli.github.com/) | GitHub CLI |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | Modern `neofetch` alternative |
| [bun](https://bun.sh/) | JavaScript runtime |

### Apps
- **[zed](https://zed.dev/)** / **[vscodium](https://vscodium.com/)** - Pretty good editors
- **[raycast](https://raycast.com/)** — Spotlight replacement
- **[shottr](https://shottr.cc/)** — Screenshot tool
- **[alt-tab](https://alt-tab-macos.netlify.app/)** — Windows-style alt-tab
- **[spotify](https://www.spotify.com/)** + **[spicetify](https://spicetify.app/)** — Themed Spotify
- **[zen](https://zen-browser.app/)** — An arc-like browser
- **[obsidian](https://obsidian.md/)** — Note-taking app
- **[appcleaner](https://freemacsoft.net/appcleaner/)** — App uninstaller

### Fonts
These are required for the icons and styling to appear correctly:
- **[Cascadia Code Nerd Font](https://github.com/microsoft/cascadia-code)** — Main terminal/coding font
- **[Sketchybar App Font](https://github.com/kvndrsslr/sketchybar-app-font)** — Required for Sketchybar icons

![Terminal Setup](Images/Cli.png)

## Installation
### Without using install.sh (Recommended)
#### Prerequisites:
* git
* The tools in the Dotfiles (Duh)

Clone the repo wherever you like.

```bash
git clone https://github.com/Yahddyyp/MacOS-Dotfiles.git && cd MacOS-Dotfiles
```

Now move them into their respective folders.

But you can move them in using stow as well:

**Install Stow** (With Homebrew)
```bash 
brew install stow 
```

And let stow create symlinks.
```bash 
# Ensure the target config directory exists
mkdir -p ~/.config

# Symlink all packages (using --restow to update and --no-folding to prevent directory issues)
stow --verbose --restow --no-folding */
```

### Using install.sh
**Warning:** This installs more than what is in the Dotfiles and mostly serves as a mean to install my setup on a different machine.

**What it does (in order)**
1. Prerequisites – Installs Homebrew (if missing), stow, and git
2. Backup – Moves any existing dotfiles (.zshrc, .tmux.conf, etc.) to ~/dotfiles-backup-<date>
3. Oh-My-Zsh – Installs oh-my-zsh (if missing)
4. Clone – Clones the repo to ~/dotfiles (or pulls latest changes if already cloned)
5. Brew Bundle – Installs all tools/apps from the Brewfile (nvim, tmux, kitty, starship, sketchybar, yabai, skhd, etc.)
6. Stow – Symlinks each package directory (zsh, tmux, nvim, etc.) into your $HOME
7. Post-install – Installs tmux plugins, Spicetify marketplace, removes Dock autohide delay, disables VSCodium press-and-hold

Using the install.sh:

```bash 
curl -fsSL https://raw.githubusercontent.com/Yahddyyp/MacOS-Dotfiles/main/install.sh | bash
```

## Post-Install 
After installation, run these:
1. tmux plugins — Open tmux and press <prefix> + I (Ctrl+A, then I)
2. Spicetify — Open Spotify once, then run `spicetify apply`
3. Start services:

   ```bash
   brew services start sketchybar
   yabai --start-service
   skhd --start-service
   ```

## Inspirations
* https://github.com/gloceansh/dotfiles
* https://github.com/typecraft-dev/dotfiles
* https://github.com/catppuccin

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>

<p align="center">Made with 💜 by Yahddyyp</p>

