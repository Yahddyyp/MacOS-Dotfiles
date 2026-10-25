#!/bin/sh

export PATH="/run/current-system/sw/bin:/opt/homebrew/bin:/etc/profiles/per-user/$(whoami)/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

SKETCHYBAR="/etc/profiles/per-user/$(whoami)/bin/sketchybar"
CONFIG_DIR="$HOME/.config/sketchybar"

ADAPTER="$CONFIG_DIR/helpers/libnowplaying.dylib"
PL_SCRIPT="$CONFIG_DIR/helpers/now-playing.pl"

# If symlinks don't exist yet, fallback to the script's local directory
if [ ! -f "$ADAPTER" ] || [ ! -f "$PL_SCRIPT" ]; then
  DIR="$(cd "$(dirname "$0")" && pwd)"
  ADAPTER="$DIR/libnowplaying.dylib"
  PL_SCRIPT="$DIR/now-playing.pl"
fi

if [ -f "$ADAPTER" ] && [ -f "$PL_SCRIPT" ]; then
  JSON="$(/usr/bin/perl "$PL_SCRIPT" "$ADAPTER" get 2>/dev/null)"
  TITLE="$(printf '%s' "$JSON" | jq -r '.kMRMediaRemoteNowPlayingInfoTitle // empty' 2>/dev/null)"
  ARTIST="$(printf '%s' "$JSON" | jq -r '.kMRMediaRemoteNowPlayingInfoArtist // empty' 2>/dev/null)"

  if [ -n "$TITLE" ]; then
    TITLE="$(printf '%s' "$TITLE" | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null | tr -d '\n\r')"
    ARTIST="$(printf '%s' "$ARTIST" | iconv -f UTF-8 -t UTF-8//IGNORE 2>/dev/null | tr -d '\n\r')"

    if [ -n "$ARTIST" ]; then
      LABEL="$ARTIST - $TITLE"
    else
      LABEL="$TITLE"
    fi

    LABEL="$(printf '%s' "$LABEL" | /usr/bin/perl -CS -Mutf8 -ne '
      sub w { my $c=ord($_[0]); return 0 if $c>=0x300&&$c<=0x36f||$c>=0xfe00&&$c<=0xfe0f; return 2 if $c>=0x1100&&$c<=0x115f||$c>=0x2e80&&$c<=0xa4cf||$c>=0xac00&&$c<=0xd7a3||$c>=0xf900&&$c<=0xfaff||$c>=0xfe30&&$c<=0xfe6f||$c>=0xff01&&$c<=0xff60||$c>=0x1f300&&$c<=0x1faff||$c>=0x20000&&$c<=0x2fa1f; return 1; }
      chomp; my $tot=0; $tot+=w($_) for split //; if ($tot<=50) { print; exit 0; }
      my $acc=0; my $out=""; for (split //) { my $cw=w($_); last if $acc+$cw>47; $out.=$_; $acc+=$cw; } $out =~ s/\s+$//; print "$out...";
    ')"

    DISPLAY_ID="$(printf '%s' "$JSON" | jq -r '.displayID // empty' 2>/dev/null)"
    PID="$(printf '%s' "$JSON" | jq -r '.pid // empty' 2>/dev/null)"
    [ -n "$DISPLAY_ID" ] && echo "$DISPLAY_ID" >/tmp/sketchybar_media_app
    [ -n "$PID" ] && echo "$PID" >/tmp/sketchybar_media_pid

    "$SKETCHYBAR" --set media.cover \
      drawing=on \
      label="$LABEL"
    exit 0
  fi
fi

rm -f /tmp/sketchybar_media_app /tmp/sketchybar_media_pid

# Fallback if no is media playing
"$SKETCHYBAR" --set media.cover drawing=off
