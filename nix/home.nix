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
    lua
    spicetify-cli
    gh-dash
    television
    gum
    nushell
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
        pager = "hunk pager";
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
      $DRY_RUN_CMD bash -c 'cd ${dotfilesDir} && find . -maxdepth 1 -type d ! -name . ! -name Images ! -name nix -exec stow --restow --no-folding --target="$HOME" {} ;' 2>/dev/null || true
    '';

    installOhMyZsh = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if [ ! -d "$HOME/.oh-my-zsh" ]; then
        export CHSH=no RUNZSH=no
        $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null
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
          $DRY_RUN_CMD gh extension install dlvhdr/gh-dash 2>/dev/null
        fi
      fi
    '';

    rebuildBatCache = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if command -v bat &>/dev/null; then
        $DRY_RUN_CMD bat cache --build 2>/dev/null || true
      fi
    '';

    installSpicetifyMarketplace = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if command -v spicetify &>/dev/null; then
        if [ ! -f "$HOME/.config/spicetify/CustomApps/marketplace/manifest.json" ]; then
          $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh)" 2>/dev/null
        fi
        $DRY_RUN_CMD spicetify backup apply 2>/dev/null || true
      fi
    '';

    installListeningStats = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      if command -v spicetify &>/dev/null; then
        if [ ! -f "$HOME/.config/spicetify/CustomApps/listening-stats/manifest.json" ]; then
          $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/Xndr2/listening-stats/main/install.sh)" 2>/dev/null
        fi
      fi
    '';

    installFisher = lib.hm.dag.entryAfter [ "restowDotfiles" ] ''
      FISH="$HOME/.nix-profile/bin/fish"
      if [ ! -x "$FISH" ]; then
        FISH="/etc/profiles/per-user/$USER/bin/fish"
      fi
      if [ -x "$FISH" ]; then
        if ! "$FISH" -c "type -q fisher" 2>/dev/null; then
          $DRY_RUN_CMD "$FISH" -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null || true
        fi
      fi
    '';
  };

  programs.home-manager.enable = true;
}
