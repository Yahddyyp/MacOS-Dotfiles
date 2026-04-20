#!/usr/bin/env bash

# Get the directory where this script is located
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

get_tmux_option() {
	local option=$1
	local default_value=$2
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

# Define the paths to your scripts
RENAME_SESSION="$CURRENT_DIR/scripts/tmux-rename-session"
RENAME_WINDOW="$CURRENT_DIR/scripts/tmux-rename-window"

# Get user options or set defaults
session_key=$(get_tmux_option "@simple-renamers-session-key" "C-e")
window_key=$(get_tmux_option "@simple-renamers-window-key" "C-w")

# Bind Rename Session
tmux bind-key "$session_key" run-shell "tmux display-popup -E -b none -x C -y 8 -w 50 -h 4 '$RENAME_SESSION #S'"

# Bind Rename Window
tmux bind-key "$window_key" run-shell "tmux display-popup -E -b none -x C -y 14 -w 50 -h 10 '$RENAME_WINDOW'"
