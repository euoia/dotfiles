#!/usr/bin/env bash
# Toggle the active pane between "90% of window height" and the layout that was
# in effect before it was grown. State is detected from geometry (so it still
# works if you resized by hand in between); the pre-grow layout is stashed in
# the window option @tall_layout, with an even-vertical fallback.
#
# Targets $TMUX_PANE (set by run-shell to the pane the key was pressed in) so it
# never operates on the wrong pane/session. Arg 1 overrides the pane (testing).
set -euo pipefail
pane="${TMUX_PANE:-${1:-}}"
[ -z "$pane" ] && pane="$(tmux display -p '#{pane_id}')"

h="$(tmux display -p -t "$pane" '#{window_height}')"
ph="$(tmux display -p -t "$pane" '#{pane_height}')"

if [ "$ph" -ge "$(( h * 85 / 100 ))" ]; then
  # Active pane already dominates -> restore the stashed layout.
  saved="$(tmux show -wv -t "$pane" @tall_layout 2>/dev/null || true)"
  tmux set -w -t "$pane" -u @tall_layout 2>/dev/null || true
  if [ -z "$saved" ] || ! tmux select-layout -t "$pane" "$saved" 2>/dev/null; then
    tmux select-layout -t "$pane" even-vertical 2>/dev/null || true
  fi
else
  # Stash the current layout, then grow.
  tmux set -w -t "$pane" @tall_layout "$(tmux display -p -t "$pane" '#{window_layout}')"
  tmux resize-pane -t "$pane" -y 90%
fi
