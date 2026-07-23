#!/usr/bin/env bash
# Find the OLDEST window still needing attention (bell flag set) and store its
# pieces in global options for the status bar to render:
#   @attention_target -> window id to jump to (empty if nothing is waiting)
#   @attention_sess / @attention_idx / @attention_name / @attention_msg
#   @attention_extra  -> " (+N more)" when more than one window waits
# The status FORMAT decides whether to show the session prefix (it hides it when
# you're already viewing that session), so it isn't baked in here.
# Ordering is by @claude_since (epoch recorded when Claude went ready); windows
# with no timestamp are treated as "just now". Flip -lt to -gt for NEWEST.
set -euo pipefail

now="$(date +%s)"
best_ts=""; best_target=""; best_sess=""; best_idx=""; best_name=""; best_msg=""; count=0

esc() { printf '%s' "$1" | sed 's/#/##/g'; }   # make text literal in tmux formats

# Tab is an IFS *whitespace* character, so `read` collapses runs of it and a
# window with an empty @claude_since would shift @claude_msg into it (a message
# read as a timestamp). tmux escapes control bytes in -F output, so the
# empty-able fields carry a "." sentinel that is stripped after the read.
SEP=$'\t'

while IFS="$SEP" read -r id sess idx name since msg; do
  [ -z "$id" ] && continue
  since="${since#.}"; msg="${msg#.}"
  count=$((count + 1))
  ts="${since:-$now}"
  case "$ts" in ''|*[!0-9]*) ts="$now" ;; esac
  if [ -z "$best_ts" ] || [ "$ts" -lt "$best_ts" ]; then
    best_ts="$ts"
    best_target="$id"
    best_sess="$(esc "$sess")"
    best_idx="$idx"
    best_name="$(esc "$name")"
    best_msg="$(esc "${msg:-needs attention}")"
  fi
done < <(tmux list-windows -a -f '#{==:#{window_bell_flag},1}' \
          -F "#{window_id}${SEP}#{session_name}${SEP}#{window_index}${SEP}#{window_name}${SEP}.#{@claude_since}${SEP}.#{@claude_msg}")

if [ -z "$best_target" ]; then
  for o in target sess idx name msg extra; do tmux set -g -u "@attention_$o" 2>/dev/null || true; done
else
  extra=""; [ "$count" -gt 1 ] && extra=" (+$((count - 1)) more)"
  tmux set -g @attention_target "$best_target"
  tmux set -g @attention_sess "$best_sess"
  tmux set -g @attention_idx "$best_idx"
  tmux set -g @attention_name "$best_name"
  tmux set -g @attention_msg "$best_msg"
  tmux set -g @attention_extra "$extra"
fi
