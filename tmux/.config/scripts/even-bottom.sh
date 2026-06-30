#!/usr/bin/env bash
# even-bottom.sh — re-balance the bottom row to equal-width columns.
# Targets every pane that is NOT flush with the top of the window
# (i.e. the row(s) below your top ai pane) and sets each to an
# equal share of the window width. Run it any time the thirds drift.
# Written for bash 3.2 (stock macOS) — no mapfile/readarray.
set -euo pipefail

# Anchor to the invoking pane (run-shell sets $TMUX_PANE) so this works
# whether or not a client is attached.
tgt="${TMUX_PANE:-}"

win_width="$(tmux display -p ${tgt:+-t "$tgt"} '#{window_width}')"

# Pane ids of the bottom row, left-to-right, excluding the top pane.
panes=()
while IFS= read -r id; do
  [ -n "$id" ] && panes+=("$id")
done < <(
  tmux list-panes ${tgt:+-t "$tgt"} -F '#{pane_left} #{pane_top} #{pane_id}' \
    | awk '$2 > 0 { print $1, $3 }' \
    | sort -n \
    | awk '{ print $2 }'
)

n="${#panes[@]}"
[ "$n" -lt 2 ] && exit 0

share="$(( win_width / n ))"
# Resize all but the last; the last absorbs the rounding remainder.
i=0
while [ "$i" -lt "$(( n - 1 ))" ]; do
  tmux resize-pane -t "${panes[$i]}" -x "$share"
  i="$(( i + 1 ))"
done
