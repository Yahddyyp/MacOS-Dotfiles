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
| [neovim](https://neovim.io/) | The best text editor that has ever lived |
| [yazi](https://yazi-rs.github.io/) | Terminal file manager |
| [btop](https://github.com/aristocratos/btop) | System monitor |
| [atuin](https://atuin.sh/) | Shell history replacement |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` on steroids  |
| [fd](https://github.com/sharkdp/fd) | `find` but fast |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |
| [sesh](https://github.com/joshmedeski/sesh) | Tmux session manager |
| [gh-dash](https://github.com/dlvhdr/gh-dash) | CLI dashboard for GitHub |
| [gh](https://cli.github.com/) | GitHub CLI |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | Better `neofetch` |
| [eza](https://github.com/eza-community/eza) | Cooler `ls` |
| [bun](https://bun.sh/) | JavaScript runtime |
| [pass](https://www.passwordstore.org/) | GPG-encrypted password manager |
| [pass-otp](https://github.com/roddhjav/pass-otp) | OTP/two-factor codes for pass |

### Apps
- **[zed](https://zed.dev/)** - Pretty good editor
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
### Drag and drop (Recommended)
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
stow --verbose --restow --no-folding --ignore=Images */
```

### Using nix
**What it does**
1. Installs packages — nix packages (fish, neovim, tmux, starship, lazygit, etc.) + brew packages (yabai, sketchybar, skhd, borders, etc.) + brew GUI apps (kitty, zed, obsidian, raycast, etc.) +
    CaskaydiaCove Nerd Font + Sketchybar App Font
2. Configures system — dock (autohide, position, size), finder (show hidden files, extensions, path bar), trackpad (tap to click), keyboard (fast repeat), dark mode, hot corner to lock screen,
    scroll bar settings, disable quarantine warnings, accent color, battery percentage
3. Sets up services — yabai scripting addition launchd, openssh
4. Stows dotfiles — symlinks all config files (zsh, nvim, tmux, kitty, ghostty, sketchybar, yabai, skhd, etc.)
5. Configures git (makes a new .gitconfig) — delta pager, catppuccin-mocha theme, user identity from secrets
6. Sets up GPG — pinentry-curses, cache TTL
7. Runs activation hooks — oh-my-zsh, tmux plugins, spicetify marketplace, gh-dash extension, bat cache rebuild
8. Enables TouchID for sudo
9. Power management — display sleep after 10 min

#### Prerequisites:
* Nix
 ``` bash 
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Clone the repo into a dir called dotfiles
```bash 
git clone https://github.com/Yahddyyp/MacOS-Dotfiles.git ~/dotfiles
```

Then setup the secrets.nix file (There is a example secrets.nix in the nix dir)
```bash 
cp ~/dotfiles/nix/secrets.nix.example ~/dotfiles/nix/secrets.nix
# Edit secrets.nix — set your MacOS username, git name/email, and GPG key you use for signing (you can leave the git items blank)
```

Then just Build
```bash 
nix run nix-darwin -- switch --flake "path:$HOME/dotfiles/nix#$(whoami)"
```

### Using install.sh (discontinued and may break)
**Warning:** This installs more than what is in the Dotfiles and mostly serves as a mean to install my setup on a different machine. This also only works on apple silicon macs and requies sudo (for yabai scripting addon).

**What it does (in order)**
1. Prerequisites – Installs Homebrew (if missing), stow, and git
2. Clone – Clones the repo to ~/dotfiles (or pulls latest changes if already cloned)
3. Oh-My-Zsh – Installs oh-my-zsh (if missing)
4. Backup – Moves any existing dotfiles (.zshrc, .tmux.conf, etc.) to ~/dotfiles-backup-<date>
5. Brew Bundle – Installs all tools/apps from the Brewfile (nvim, tmux, kitty, starship, sketchybar, yabai, skhd, aerospace, etc.)
6. Stow – Symlinks each package directory (zsh, tmux, nvim, etc.) into your $HOME
7. Git Config – Configures delta as the git pager with Catppuccin Mocha theme (via `include.path` + `delta.features`), and restores your git name/email from backup if needed
8. Post-install – Spicetify marketplace, removes Dock autohide delay, copies and loads the yabai scripting addition LaunchDaemon, and some other stuff

Using the install.sh:

```bash 
curl -fsSL https://raw.githubusercontent.com/Yahddyyp/MacOS-Dotfiles/main/install.sh | bash
```

## Post-Install 
After installation, run these:
1. Tmux plugins — Open tmux and press prefix + I (Ctrl+A, then I)
2. Spicetify — Open Spotify once, then run `spicetify apply`
3. Disable SIP for yabai (Apple Silicon only):
   1. Reboot into recovery mode (hold power button while restarting)
   2. Open terminal and run:

      ```bash
      csrutil enable --without fs --without debug --without nvram
      ```
   3. Enable non-Apple-signed arm64e binaries, then reboot:

      ```bash
      sudo nvram boot-args=-arm64e_preview_abi
      ```

4. Load the scripting addon:

   ```bash 
   sudo yabai --load-sa
   ```

> [!TIP]
> A LaunchDaemon plist is included in the `yabai` directory to load the scripting addition automatically on boot. Copy it to `/Library/LaunchDaemons/` and run `sudo launchctl load -w /Library/LaunchDaemons/com.asmvik.yabai-sa.plist`. (You don't have to do this if you used nix)

5. Start services:

   ```bash
   brew services start sketchybar
   yabai --start-service
   skhd --start-service
   ```

## Inspirations
* https://github.com/gloceansh/dotfiles
* https://github.com/typecraft-dev/dotfiles
* https://github.com/catppuccin
* https://github.com/omerxx/dotfiles

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>

<p align="center">Made with 💜 by Yahddyyp</p>

