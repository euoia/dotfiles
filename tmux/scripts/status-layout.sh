#!/usr/bin/env bash
# Lay out the double-height status bar with the two rows REVERSED from tmux's
# usual stacking: the window picker on the BOTTOM (line 1) and the info line on
# TOP (line 0).
#
# Info line = focused window's current Claude task on the LEFT, and the oldest
# window still needing attention (+ its message) on the RIGHT, so the two never
# clobber each other.
#
# The picker format is tmux's built-in default, captured once into
# picker-format.txt (next to this script). We read it from there rather than
# from `status-format[0]` because unsetting an array element empties it instead
# of reverting to the compiled-in default. If tmux's default ever changes
# (version upgrade) and you want the new one, run from a fresh server:
#   tmux show -gv 'status-format[0]' > ~/.tmux/scripts/picker-format.txt
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
picker_file="$here/picker-format.txt"

if [ ! -s "$picker_file" ]; then
  tmux display-message "status-layout: picker-format.txt missing — leaving status as-is"
  exit 0
fi

picker="$(cat "$picker_file")"

tmux set -g 'status-format[1]' "$picker"          # picker  -> bottom row
tmux set -g 'status-format[0]' \
  '#[align=left]#[fg=colour109]#{pane_title}#[align=right]#{@attention_line}'   # info -> top row
