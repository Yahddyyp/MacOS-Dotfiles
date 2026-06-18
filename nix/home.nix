{ pkgs, lib, username, ... }:

let
  dotfilesDir = builtins.toString ./..;
  secrets = if builtins.pathExists ./secrets.nix then import ./secrets.nix else { };
in {
  home.username = username;
  home.homeDirectory = lib.mkForce (builtins.toPath ("/Users/" + username));

  home.stateVersion = "24.11";

  #home packages
  home.packages = with pkgs; [
    fish
    tmux
    kitty
    neovim
    starship
    bun
    nodejs
    atuin
    bandwhich
    btop
    fastfetch
    yazi
    eza
    fd
    ripgrep
    bat
    tree
    zoxide
    fzf
    git
    lazygit
    gh
    delta
    duf
    dust
    gdu
    ouch
    _7zz
    ffmpeg
    imagemagick
    jq
    just
    pinentry-curses
    stow
    luarocks
    ngrok
    cbonsai
    sesh
    opencode
    pi-coding-agent
    mole
    lua
    spicetify-cli
    gh-dash
    television
    tailscale
    gum
  ];

  #git config 
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = secrets.git.userName or "";
        email = secrets.git.userEmail or "";
        signingkey = secrets.git.signingKey or "";
      };
      core = {
        editor = "nvim";
        pager = "delta";
      };
      credential.helper = "osxkeychain";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        line-numbers = true;
        features = "catppuccin-mocha";
      };
      include.path = "$HOME/.config/lazygit/catppuccin-mocha-delta.gitconfig";
    };
  };

  #gpg agent config
  services.gpg-agent = {
    enable = true;
    pinentry = {
      package = pkgs.pinentry-curses;
    };
    defaultCacheTtl = 600;
    maxCacheTtl = 600;
  };

  #Extra stuff
  home.activation = {
    restowDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Stowing dotfiles from ${dotfilesDir}..."
      $DRY_RUN_CMD bash -c 'cd ${dotfilesDir} && find . -maxdepth 1 -type d ! -name . ! -name Images ! -name nix -exec stow --restow --no-folding --target="$HOME" {} ;' 2>/dev/null || true
    '';

    installOhMyZsh = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."
        export CHSH=no RUNZSH=no
        $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
      fi
    '';

    installTmuxPlugins = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
        $DRY_RUN_CMD "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
      fi
    '';

    installGhDash = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if command -v gh &>/dev/null; then
        if ! gh extension list 2>/dev/null | grep -q "gh-dash"; then
          echo "Installing gh-dash extension..."
          $DRY_RUN_CMD gh extension install dlvhdr/gh-dash
        fi
      fi
    '';

    rebuildBatCache = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if command -v bat &>/dev/null; then
        echo "Rebuilding bat cache..."
        $DRY_RUN_CMD bat cache --build 2>/dev/null || true
      fi
    '';

    installSpicetifyMarketplace = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if command -v spicetify &>/dev/null; then
        if [ ! -f "$HOME/.config/spicetify/Marketplace" ]; then
          echo "Installing spicetify marketplace..."
          $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh)"
        fi
        $DRY_RUN_CMD spicetify backup apply 2>/dev/null || true
      fi
    '';
  };

  programs.home-manager.enable = true;
}
