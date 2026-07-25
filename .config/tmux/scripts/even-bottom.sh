#!/usr/bin/env bash
# even-bottom.sh — re-balance the bottom row to equal-width columns.
# Targets the lowest row of panes (the row with the largest pane_top,
# i.e. the columns below your top ai pane) and sets each to an equal
# share of the window width. Run it any time the thirds drift.
# Note: the top pane's pane_top is 1, not 0, when pane-border-status is
# on, so the row is picked by max pane_top rather than "top > 0".
# Written for bash 3.2 (stock macOS) — no mapfile/readarray.
set -euo pipefail

# Anchor to the invoking pane (run-shell sets $TMUX_PANE) so this works
# whether or not a client is attached.
tgt="${TMUX_PANE:-}"

win_width="$(tmux display -p ${tgt:+-t "$tgt"} '#{window_width}')"

# Pane ids of the bottom row, left-to-right, excluding higher rows.
panes=()
while IFS= read -r id; do
  [ -n "$id" ] && panes+=("$id")
done < <(
  tmux list-panes ${tgt:+-t "$tgt"} -F '#{pane_top} #{pane_left} #{pane_id}' \
    | awk '
        { top[NR] = $1; left[NR] = $2; id[NR] = $3; if ($1 > max) max = $1 }
        END { for (i = 1; i <= NR; i++) if (top[i] == max) print left[i], id[i] }
      ' \
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
