#!/usr/bin/env bash
set -euo pipefail

HOME="${HOME:-/var/root}"

export PATH="/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/system/sw/bin:$PATH"

PROFILES=()

if [ -L /nix/var/nix/profiles/system ]; then
  PROFILES+=(/nix/var/nix/profiles/system)
fi

for p in /nix/var/nix/profiles/per-user/*/profile; do
  [ -L "$p" ] && PROFILES+=("$p")
done
for p in /nix/var/nix/profiles/per-user/*/channels; do
  [ -L "$p" ] && PROFILES+=("$p")
done

USER_PROFILES_DIR="$HOME/.local/state/nix/profiles"
if [ -d "$USER_PROFILES_DIR" ]; then
  for p in "$USER_PROFILES_DIR"/*; do
    [ -L "$p" ] && PROFILES+=("$p")
  done
fi

for p in "$HOME/.nix-profile" /nix/var/nix/profiles/default; do
  [ -L "$p" ] && PROFILES+=("$p")
done

echo "=== Cleaning up old generations (keeping last 3) ==="
for profile in "${PROFILES[@]}"; do
  # Deduplicate by resolving symlinks
  resolved=$(readlink -f "$profile" 2>/dev/null || readlink "$profile")
  if [ -n "$resolved" ]; then
    echo "  Profile: $profile -> $resolved"
    nix-env --profile "$profile" --delete-generations +3 2>&1 | sed 's/^/    /'
  fi
done

echo ""
echo "=== Running garbage collection ==="
nix-store --gc 2>&1 | sed 's/^/  /'

echo ""
echo "=== Done ==="
