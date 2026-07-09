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
| [neovim](https://neovim.io/) | The greatest text editor that has ever lived |
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
| [pass-otp](https://github.com/tadfisher/pass-otp) | OTP/two-factor codes for pass |

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
- **[CascadiaCove Nerd Font](https://github.com/eliheuer/caskaydia-cove)** — Main font
- **[Sketchybar App Font](https://github.com/kvndrsslr/sketchybar-app-font)** — Required for Sketchybar icons

![Terminal Setup](Images/Cli.png)

## Installation (Using nix)
### Prerequisites:
* Nix
 ``` bash 
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```


**What it does**
1. Installs packages — nix packages + brew packages + brew GUI apps + CaskaydiaCove Nerd Font + Sketchybar App Font
2. Configures system — dock, finder, trackpad, keyboard, dark mode, hot corner to lock screen,scroll bar settings, disable quarantine warnings, accent color, battery percentage
3. Sets up services — yabai scripting addition launchd, openssh
4. Stows dotfiles — symlinks all config files 
5. Configures git (makes a new .gitconfig) — delta pager, catppuccin-mocha theme, user identity from secrets
6. Sets up GPG (for pass) — pinentry-curses, cache TTL
7. Runs activation hooks — oh-my-zsh, tmux plugins, spicetify marketplace, gh-dash extension, bat cache rebuild, installs babysitter for pi, some more things
8. Enables TouchID for sudo
9. Display sleep after 10 min


Clone the repo into a dir called dotfiles
```bash 
git clone https://github.com/Yahddyyp/MacOS-Dotfiles.git ~/dotfiles
```

Then setup the secrets.nix file (There is a example secrets.nix in the nix dir)
```bash 
# Edit secrets.nix — set your MacOS username, git name/email, and GPG key you use for signing (you can leave the git items blank)
cp ~/dotfiles/nix/secrets.nix.example ~/dotfiles/nix/secrets.nix
```

Apply the configuration
```bash 
nix run nix-darwin -- switch --flake "path:$HOME/dotfiles/nix#$(whoami)"
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

