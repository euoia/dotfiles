#!/usr/bin/env bash
# Rename a session after the projects it actually contains — the session-level
# twin of autoname.sh. Sessions are otherwise called "0", "5", "8"…, which tells
# you nothing when you have six of them.
#
#   session-autoname.sh [session]
#
# The name is the distinct directory labels of the session's panes (dirlabel.sh
# rules), most-used first, up to 2, joined with "+": e.g. "snib+forge".
# Collisions get a -2, -3 … suffix. Manual `prefix $` still wins — this is a
# command, never automatic.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

sess="${1:-$(tmux display-message -p '#{session_name}')}"

# Count panes per directory, most-used first, then map each to a short label.
labels=""
while read -r path; do
  [ -z "$path" ] && continue
  label="$("$here/dirlabel.sh" "$path")"
  [ -z "$label" ] && continue
  case " $labels " in *" $label "*) continue ;; esac
  labels="${labels:+$labels }$label"
done < <(tmux list-panes -s -t "$sess:" -F '#{pane_current_path}' \
           | sort | uniq -c | sort -rn | sed -E 's/^ *[0-9]+ //')

# Top label, plus the second only if the pair still reads at a glance — a
# mid-word truncation ("3d-printing+blackshuckfe") is worse than one clean name.
name="$(printf '%s' "$labels" \
        | awk '{ n = $1; if ($2 != "" && length($1 "+" $2) <= 20) n = $1 "+" $2; print n }' \
        | tr ':.' '--' | cut -c1-20)"

if [ -z "$name" ]; then
  tmux display-message "session-autoname: no directories to name '$sess' from"
  exit 0
fi

# Uniquify against the other sessions.
existing="$(tmux list-sessions -F '#{session_name}')"
candidate="$name"; n=1
while printf '%s\n' "$existing" | grep -qxF "$candidate" \
      && [ "$candidate" != "$sess" ]; do
  n=$((n + 1)); candidate="$name-$n"
done

if [ "$candidate" = "$sess" ]; then exit 0; fi   # already named correctly
# Trailing colon: a bare "2" would be read as window 2 of the CURRENT session.
tmux rename-session -t "$sess:" "$candidate"
tmux display-message "session renamed to '$candidate'"
