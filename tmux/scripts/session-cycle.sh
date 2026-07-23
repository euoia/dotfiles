#!/usr/bin/env bash
# Move to the next / previous ACTIVE session, skipping parked ones (@parked).
#
#   session-cycle.sh [next|prev] [--dry]      (--dry prints the target instead)
#
# Order is tmux's own session order (alphabetical by name), wrapping around. If
# the current session is parked you're outside the ring, so this drops you at
# the first active session.
set -euo pipefail

dir="${1:-next}"
cur="$(tmux display-message -p '#{session_name}')"

names=""
while IFS=$'\t' read -r name parked; do
  [ -z "$name" ] && continue
  [ "$parked" = "1" ] && continue
  names="${names}${name}"$'\n'
done < <(tmux list-sessions -F '#{session_name}	#{?@parked,1,0}')

names="$(printf '%s' "$names" | sed '/^$/d')"
count="$(printf '%s\n' "$names" | grep -c . || true)"

if [ -z "$names" ] || [ "$count" -lt 1 ]; then
  tmux display-message "no active sessions (all parked?)"
  exit 0
fi

# Index of the current session within the active ring (0 if it isn't in it).
idx="$(printf '%s\n' "$names" | grep -nxF -- "$cur" | head -1 | cut -d: -f1 || true)"
if [ -z "$idx" ]; then
  target="$(printf '%s\n' "$names" | head -1)"
else
  if [ "$dir" = "prev" ]; then
    next=$(( (idx - 2 + count) % count + 1 ))
  else
    next=$(( idx % count + 1 ))
  fi
  target="$(printf '%s\n' "$names" | sed -n "${next}p")"
fi

if [ "${2:-}" = "--dry" ]; then
  printf '%s\n' "$target"
elif [ -n "$target" ] && [ "$target" != "$cur" ]; then
  tmux switch-client -t "=$target"
fi
exit 0
