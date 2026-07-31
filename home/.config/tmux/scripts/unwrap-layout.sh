#!/usr/bin/env bash
# unwrap-layout.sh — collapse the dev layout back to a single pane,
# keeping the ai pane (the one tagged @role ai). If no pane is
# tagged ai, the currently-active pane is kept instead.
#
# WARNING: this kills the other panes outright (nvim/lazygit/terminal).
# Any unsaved work in them is lost — same as closing a pane.
set -euo pipefail

# Anchor to the invoking pane (run-shell sets $TMUX_PANE).
tgt="${TMUX_PANE:-$(tmux display -p '#{pane_id}')}"

# Prefer the ai-tagged pane; fall back to the invoking/active pane.
keep="$(
  tmux list-panes ${tgt:+-t "$tgt"} -F '#{@role} #{pane_id}' \
    | awk '$1 == "ai" { print $2; exit }'
)"
keep="${keep:-$tgt}"

# Kill every pane in this window except the one we're keeping.
tmux kill-pane -a -t "$keep"
tmux select-pane -t "$keep"
