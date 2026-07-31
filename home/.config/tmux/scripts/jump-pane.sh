#!/usr/bin/env bash
# jump-pane.sh — select the pane in the current window whose @role matches.
# Usage: jump-pane.sh <role>   (e.g. ai | editor | git | terminal)
# Roles are set by dev-layout.sh via `tmux set -p @role <name>`.
set -euo pipefail

role="${1:?usage: jump-pane.sh <role>}"

# Anchor to the invoking pane (run-shell sets $TMUX_PANE) so the lookup
# stays within the right window whether or not a client is attached.
tgt="${TMUX_PANE:-}"

pane="$(
  tmux list-panes ${tgt:+-t "$tgt"} -F '#{@role} #{pane_id}' \
    | awk -v r="$role" '$1 == r { print $2; exit }'
)"

if [ -n "${pane:-}" ]; then
  tmux select-pane -t "$pane"
else
  # No pane tagged with this role — this window probably wasn't built by
  # dev-layout.sh. Tell the user on the status line instead of erroring.
  tmux display-message "jump-pane: no '$role' pane in this window (rebuild with prefix+D)"
fi
