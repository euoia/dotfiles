#!/usr/bin/env bash
# Reorder the windows of a session so windows sharing a directory label are
# adjacent (sorted by label), and reprefix each name to <label>:<old-suffix>.
# Arg 1: session name (defaults to current). Pass "all" to do every session.
#
# Assumptions: `renumber-windows` is off (default) so parked indices don't shift
# mid-operation; session names contain no ':' (they build `session:index`
# targets by concatenation). Both hold for this setup (sessions are 0/1/2).
# Fails safe: the build loop runs entirely before any move, and every move is
# `|| true`-guarded, so a mid-run error never leaves windows parked at 1000+.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

newname_for() {   # $1=label $2=oldname  -> prints reprefixed name
  local label="$1" oldname="$2" suffix
  case "$oldname" in
    *:*)      suffix="${oldname#*:}" ;;   # keep chosen topic after first colon
    "$label") suffix="" ;;
    *)        suffix="$oldname" ;;        # no colon and differs -> keep as suffix
  esac
  if [ -n "$suffix" ]; then printf '%s:%s' "$label" "$suffix"; else printf '%s' "$label"; fi
}

reorder_session() {
  local sess="$1"
  local base; base="$(tmux show -gv base-index 2>/dev/null || echo 0)"
  [ -z "$base" ] && base=0

  # Build sort lines: <label>\t<orig_index_zeropad>\t<window_id>\t<newname>
  local lines="" id path idx oldname label newname
  while IFS=$'\t' read -r id path idx oldname; do
    [ -z "$id" ] && continue
    label="$("$here/dirlabel.sh" "$path")"
    newname="$(newname_for "$label" "$oldname")"
    lines+="$(printf '%s\t%010d\t%s\t%s' "$label" "$idx" "$id" "$newname")"$'\n'
  done < <(tmux list-windows -t "$sess" \
             -F '#{window_id}	#{pane_current_path}	#{window_index}	#{window_name}')

  # Sort by label, then original index.
  local ordered
  ordered="$(printf '%s' "$lines" | LC_ALL=C sort -t$'\t' -k1,1 -k2,2)"

  # Phase 1: park all windows at high indices to avoid target collisions.
  local n="$base"
  while IFS=$'\t' read -r label idx id newname; do
    [ -z "$id" ] && continue
    tmux move-window -d -s "$id" -t "$sess:$((n + 1000))" 2>/dev/null || true
    n=$((n + 1))
  done <<< "$ordered"

  # Phase 2: move into final positions (window ids are stable) and rename.
  n="$base"
  while IFS=$'\t' read -r label idx id newname; do
    [ -z "$id" ] && continue
    tmux move-window -d -s "$id" -t "$sess:$n" 2>/dev/null || true
    tmux rename-window -t "$id" "$newname" 2>/dev/null || true
    n=$((n + 1))
  done <<< "$ordered"
}

target="${1:-$(tmux display -p '#{session_name}')}"
if [ "$target" = "all" ]; then
  while IFS= read -r s; do reorder_session "$s"; done \
    < <(tmux list-sessions -F '#{session_name}')
else
  reorder_session "$target"
fi
tmux display-message "Reordered windows by directory"
