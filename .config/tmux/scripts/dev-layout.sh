#!/usr/bin/env bash
# dev-layout.sh — build the standard dev layout in the CURRENT window:
#
#   ┌──────────────────────────────┐
#   │              ai              │  top, ~70% height
#   ├────────┬─────────┬───────────┤
#   │  nvim  │ lazygit │ terminal  │  bottom row, exact 1/3 each
#   └────────┴─────────┴───────────┘
#
# Usage: dev-layout.sh [dir] [window-name]
#   dir          directory to open everything in   (default: current pane path)
#   window-name  rename the window                 (default: basename of dir)
set -euo pipefail

# Percentage of window height given to the bottom work row
# (vim/lazygit/terminal). The top ai pane gets the rest.
BOTTOM_PCT=50

# Anchor to the invoking pane (run-shell sets $TMUX_PANE).
top="${TMUX_PANE:-$(tmux display -p '#{pane_id}')}"

dir="${1:-$(tmux display -p -t "$top" '#{pane_current_path}')}"
name="${2:-$(basename "$dir")}"

# tmux rejects window names starting with '.', so strip leading dots
# (e.g. a dotfiles ".config" dir) and fall back to a sane default.
name="${name#.}"
[ -z "$name" ] && name="dev"

tmux rename-window -t "$top" -- "$name"

# Carve the bottom row at 30% of window height.
left="$(tmux split-window -v -l "${BOTTOM_PCT}%" -c "$dir" -P -F '#{pane_id}')"
# Split that bottom pane twice to make three columns.
mid="$(tmux split-window -h -t "$left" -c "$dir"  -P -F '#{pane_id}')"
right="$(tmux split-window -h -t "$mid" -c "$dir"  -P -F '#{pane_id}')"

# Force exact thirds: set the two left columns to width/3, the rest fills.
win_width="$(tmux display -p '#{window_width}')"
third="$(( win_width / 3 ))"
tmux resize-pane -t "$left" -x "$third"
tmux resize-pane -t "$mid"  -x "$third"

# Tag each pane with a stable @role (for jump-to-pane shortcuts) and a
# display title (shown on the pane border). Roles survive index changes.
tmux set -p -t "$top"   @role ai       ; tmux select-pane -t "$top"   -T ai
tmux set -p -t "$left"  @role editor   ; tmux select-pane -t "$left"  -T editor
tmux set -p -t "$mid"   @role git      ; tmux select-pane -t "$mid"   -T git
tmux set -p -t "$right" @role terminal ; tmux select-pane -t "$right" -T terminal

# Launch the programs.
tmux send-keys -t "$left"  'nvim .'  C-m
tmux send-keys -t "$mid"   'lazygit' C-m
# right pane stays a plain shell.

# Land cursor on the top pane and start ai harness there.
tmux send-keys -t "$top" 'claude' C-m
tmux select-pane -t "$top"
