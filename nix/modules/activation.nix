{ lib, ... }:
let
  toolPath = ''export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"'';
in {
  home.activation = {
    installOhMyZsh = lib.hm.dag.entryAfter [ "installPackages" ] ''
      (
        ${toolPath}
        if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
          TMPZSH=$(mktemp -d)
          export CHSH=no RUNZSH=no ZSH="$TMPZSH"
          $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true
          $DRY_RUN_CMD cp -R "$TMPZSH/." "$HOME/.oh-my-zsh/" 2>/dev/null || true
          $DRY_RUN_CMD rm -rf "$TMPZSH"
        fi
      )
    '';

    linkP10kTheme = lib.hm.dag.entryAfter [ "installPackages" ] ''
      (
        ${toolPath}
        i=0
        while [ ! -d /opt/homebrew/share/powerlevel10k ] && [ $i -lt 60 ]; do
          sleep 2
          i=$((i + 1))
        done
        if [ -d /opt/homebrew/share/powerlevel10k ] && [ ! -e "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
          $DRY_RUN_CMD mkdir -p "$HOME/.oh-my-zsh/custom/themes"
          $DRY_RUN_CMD ln -s /opt/homebrew/share/powerlevel10k "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
        fi
      )
    '';

    installTmuxPlugins = lib.hm.dag.entryAfter [ "installPackages" ] ''
      (
        ${toolPath}
        if [ ! -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
          $DRY_RUN_CMD rm -rf "$HOME/.tmux/plugins/tpm"
          $DRY_RUN_CMD mkdir -p "$HOME/.tmux/plugins"
          $DRY_RUN_CMD git clone --depth 1 --quiet https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null || true
        fi
        if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
          $DRY_RUN_CMD "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
        fi
      )
    '';

    rebuildBatCache = lib.hm.dag.entryAfter [ "installPackages" ] ''
      (
        ${toolPath}
        if command -v bat &>/dev/null; then
          $DRY_RUN_CMD bat cache --build 2>/dev/null || true
        fi
      )
    '';

    installSpicetifyMarketplace = lib.hm.dag.entryAfter [ "installPackages" ] ''
      (
        ${toolPath}
        if command -v spicetify &>/dev/null; then
          if [ ! -f "$HOME/.config/spicetify/CustomApps/marketplace/manifest.json" ]; then
            $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh)" 2>/dev/null || true
            $DRY_RUN_CMD spicetify backup apply 2>/dev/null || true
          fi
        fi
      )
    '';

    installListeningStats = lib.hm.dag.entryAfter [ "installPackages" ] ''
      (
        ${toolPath}
        if command -v spicetify &>/dev/null; then
          if [ ! -f "$HOME/.config/spicetify/CustomApps/listening-stats/manifest.json" ]; then
            $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/Xndr2/listening-stats/main/install.sh)" 2>/dev/null || true
          fi
        fi
      )
    '';
  };
}
