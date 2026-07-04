#!/usr/bin/env bash
# Jump to the next window that needs attention (bell flag set), cycling through
# all such windows across every session. If none, say so.
# Written for bash 3.2 (macOS system bash) — no mapfile / associative arrays.
set -euo pipefail

# Collect bell-flagged windows by unique window id (colon-in-session safe).
attn=""
while IFS= read -r w; do
  [ -z "$w" ] && continue
  attn="$attn$w"$'\n'
done < <(tmux list-windows -a -f '#{==:#{window_bell_flag},1}' \
                          -F '#{window_id}')

if [ -z "$attn" ]; then
  tmux display-message "No windows need attention"
  exit 0
fi

cur="$(tmux display -p '#{window_id}')"

# Pick the first attention window strictly after the current one (wrapping);
# if the current window isn't in the list, pick the first.
first=""
pick=""
take_next=0
while IFS= read -r w; do
  [ -z "$w" ] && continue
  [ -z "$first" ] && first="$w"
  if [ "$take_next" = "1" ]; then pick="$w"; break; fi
  if [ "$w" = "$cur" ]; then take_next=1; fi
done <<< "$attn"

[ -z "$pick" ] && pick="$first"
tmux switch-client -t "$pick"
