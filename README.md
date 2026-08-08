# MacOS Dotfiles

![Full Setup](assets/Desktop.jpeg)

![Terminal Setup](assets/Cli.png)

## Installation (Using nix)
### Prerequisites:
* Xcode Command Line Tools
```bash
xcode-select --install
```

* Nix
```bash
curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --daemon
```

Clone the repo into a dir called dotfiles:
```bash
git clone https://github.com/Yahddyyp/MacOS-Dotfiles.git ~/dotfiles
```

>[!Note] 
> git username/email are hardcoded in `nix/modules/git.nix` (edit them there).

Set up `/etc/nix-darwin`:
```bash
sudo ln -s "$HOME/dotfiles/nix" /etc/nix-darwin
```

Apply the configuration
First build only:

```bash
nix run nix-darwin -- switch --flake /etc/nix-darwin#$(whoami) --impure
```

Every build after that is the same:

```bash
sudo darwin-rebuild switch --flake /etc/nix-darwin#$(whoami) --impure
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
   source ~/.zshrc
   start-yabai
   ```

## First Login
* Authenticate gh (git uses it as the credential helper):
  ```bash
  gh auth login
  ```

* Restore your GPG key and pass store:
  ```bash
  gpg --import <secret-key.asc>
  gpg --quick-set-ownertrust <KEYID> ultimate
  ```

## macOS Settings

These dotfiles configure macOS declaratively, but a lot of the system lives behind `defaults write` commands that never make it into a config file. For the GUI-toggle settings — Finder, Dock, keyboard, trackpad, privacy, screenshots — I use [Mainspring](https://trymainspring.com): a menu bar app that turns 90+ of them into labelled, reversible toggles, each with an undo, and keeps a record of what you changed. Handy alongside a nix-darwin setup for the bits that are awkward to declare.

## Inspirations
* https://github.com/gloceansh/dotfiles
* https://github.com/typecraft-dev/dotfiles
* https://github.com/catppuccin
* https://github.com/omerxx/dotfiles

<p align="center"><img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/footers/gray0_ctp_on_line.svg?sanitize=true" /></p>

<p align="center">Made with 💜 by Yahddyyp</p>
