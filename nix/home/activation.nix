{ lib, ... }:
let
  toolPath = ''export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"'';
in {
  home.activation = {
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
