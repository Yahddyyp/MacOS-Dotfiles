#!/usr/bin/env bash
set -uo pipefail

if [ -n "${1:-}" ] && [ -d "$1" ]; then
  USER_HOME="$1"
else
  USER_HOME="${HOME:-/var/root}"
fi

export PATH="/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/system/sw/bin:$PATH"

if [ -n "${HOME:-}" ] && [ "$(stat -f '%u' "$HOME" 2>/dev/null || echo 0)" != "$(id -u)" ]; then
  unset HOME
fi

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

USER_PROFILES_DIR="$USER_HOME/.local/state/nix/profiles"
if [ -d "$USER_PROFILES_DIR" ]; then
  for p in "$USER_PROFILES_DIR"/*; do
    [ -L "$p" ] && PROFILES+=("$p")
  done
fi

for p in "$USER_HOME/.nix-profile" /nix/var/nix/profiles/default; do
  [ -L "$p" ] && PROFILES+=("$p")
done

echo "Cleaning up old generations (keeping last 3)"
FAILED=0
for profile in "${PROFILES[@]}"; do
  resolved=$(readlink -f "$profile" 2>/dev/null || readlink "$profile")
  if [ -n "$resolved" ]; then
    echo "  Profile: $profile -> $resolved"
    if ! nix-env --profile "$profile" --delete-generations +3 2>&1 | sed 's/^/    /'; then
      echo "    !! failed to clean profile $profile (continuing)" >&2
      FAILED=1
    fi
  fi
done

echo ""
echo "Running garbage collection"
if ! nix-store --gc 2>&1 | sed 's/^/  /'; then
  echo "!! nix-store --gc failed" >&2
  exit 1
fi

echo ""
echo "Done"
exit "$FAILED"
