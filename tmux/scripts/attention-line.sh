#!/usr/bin/env bash
# Compute a single status line for the OLDEST window still needing attention
# (bell flag set), and store it in global options the status bar reads:
#   @attention_line   -> styled text (empty if nothing is waiting)
#   @attention_target -> "session:window_id" to jump to (empty if none)
# Ordering is by @claude_since (epoch recorded when Claude went ready); windows
# with no timestamp are treated as "just now" so they don't falsely dominate.
# To surface the NEWEST instead, flip the comparison from -lt to -gt below.
set -euo pipefail

now="$(date +%s)"
best_ts=""; best_target=""; best_line=""; count=0

esc() { printf '%s' "$1" | sed 's/#/##/g'; }   # make text literal in tmux formats

while IFS=$'\t' read -r id sess idx name since msg; do
  [ -z "$id" ] && continue
  count=$((count + 1))
  ts="${since:-$now}"
  case "$ts" in ''|*[!0-9]*) ts="$now" ;; esac
  if [ -z "$best_ts" ] || [ "$ts" -lt "$best_ts" ]; then
    best_ts="$ts"
    best_target="$id"                       # bare window id: colon-in-session safe
    desc="$(esc "${msg:-needs attention}")"
    name="$(esc "$name")"
    sess_e="$(esc "$sess")"
    best_line="#[fg=black,bg=colour214] ⚑ $sess_e:$idx $name #[fg=colour214,bg=default] $desc#[default]"
  fi
done < <(tmux list-windows -a -f '#{==:#{window_bell_flag},1}' \
          -F '#{window_id}	#{session_name}	#{window_index}	#{window_name}	#{@claude_since}	#{@claude_msg}')

if [ -z "$best_target" ]; then
  tmux set -g @attention_line ""
  tmux set -g @attention_target ""
else
  [ "$count" -gt 1 ] && best_line="$best_line #[fg=colour244](+$((count - 1)) more)#[default]"
  tmux set -g @attention_line "$best_line"
  tmux set -g @attention_target "$best_target"
fi
