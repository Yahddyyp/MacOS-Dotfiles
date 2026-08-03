{ lib, ... }:
let
  toolPath = ''export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"'';
in
{
  home.activation = {
    installOhMyZsh = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${toolPath}
      if [ ! -d "$HOME/.oh-my-zsh" ]; then
        export CHSH=no RUNZSH=no
        $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true
      fi
    '';
    installTmuxPlugins = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${toolPath}
      if [ ! -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
        $DRY_RUN_CMD rm -rf "$HOME/.tmux/plugins/tpm"
        mkdir -p "$HOME/.tmux/plugins"
        $DRY_RUN_CMD git clone --depth 1 --quiet https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null || true
      fi
      if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
        $DRY_RUN_CMD "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
      fi
    '';
    installGhDash = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${toolPath}
      if command -v gh &>/dev/null; then
        if ! gh extension list 2>/dev/null | grep -q "gh-dash"; then
          $DRY_RUN_CMD gh extension install dlvhdr/gh-dash 2>/dev/null || true
        fi
      fi
    '';
    rebuildBatCache = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${toolPath}
      if command -v bat &>/dev/null; then
        $DRY_RUN_CMD bat cache --build 2>/dev/null || true
      fi
    '';
    installSpicetifyMarketplace = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${toolPath}
      if command -v spicetify &>/dev/null; then
        if [ ! -f "$HOME/.config/spicetify/CustomApps/marketplace/manifest.json" ]; then
          $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh)" 2>/dev/null || true
          $DRY_RUN_CMD spicetify backup apply 2>/dev/null || true
        fi
      fi
    '';
    installListeningStats = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${toolPath}
      if command -v spicetify &>/dev/null; then
        if [ ! -f "$HOME/.config/spicetify/CustomApps/listening-stats/manifest.json" ]; then
          $DRY_RUN_CMD sh -c "$(curl -fsSL https://raw.githubusercontent.com/Xndr2/listening-stats/main/install.sh)" 2>/dev/null || true
        fi
      fi
    '';
  };
}
