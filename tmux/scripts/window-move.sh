#!/usr/bin/env bash
# Move this window to another session, chosen from a picker — tmux's built-in
# `prefix .` asks you to *type* a session name, which is no use when the
# sessions are called 0, 5 and 8.
#
#   window-move.sh [window-id …]
#
# No ids = the current window. Rows are the same session picker as prefix Tab
# (projects, window count, waiting flag, last seen), minus the session the
# window is already in, plus a "new session" row for when everything is full.
# You stay where you are and land on the neighbour — unless the window was the
# last one in its session, in which case there is nothing to stay for and the
# client follows it.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

FZF="/opt/homebrew/bin/fzf"; [ -x "$FZF" ] || FZF="fzf"
TMUX_BIN="/opt/homebrew/bin/tmux"; [ -x "$TMUX_BIN" ] || TMUX_BIN="tmux"
NEW_ROW_ID='=+new+='            # sentinel; not a legal tmux session name

OFF=$'\033[0m'; GREEN=$'\033[32m'

wins=("$@")
if [ "${#wins[@]}" -eq 0 ]; then
  wins=("$("$TMUX_BIN" display-message -p ${TMUX_PANE:+-t "$TMUX_PANE"} '#{window_id}')")
fi
win="${wins[0]}"

info="$("$TMUX_BIN" display-message -p -t "$win" '#{session_name}	#{window_name}	#{pane_current_path}')"
src="$(printf '%s' "$info" | cut -f1)"
wname="$(printf '%s' "$info" | cut -f2)"
wpath="$(printf '%s' "$info" | cut -f3)"

# The session picker's own rows, minus the session we're already in.
rows="$("$here/sessions.sh" --list | awk -F'\t' -v me="$src" '$1 != me')"
rows="${rows}"$'\n'"$(printf '%s\t%s+ new session%s' "$NEW_ROW_ID" "$GREEN" "$OFF")"

# The preview must do nothing on a group-header row: its id field is empty, and
# `list-windows -t :` quietly falls back to the CURRENT session, so the header
# rows previewed the windows of the session you're moving out of.
# --header-lines=1 pins sessions.sh's leading "active" line, which also puts the
# cursor on a real session from the start.
preview="[ -n {1} ] && $TMUX_BIN list-windows -t {1}: -F '#{?#{==:#{window_bell_flag},1},⚑ ,  }#{window_index}: #{window_name}   #{pane_title}' 2>/dev/null | cut -c1-200"

sel="$(printf '%s\n' "$rows" | "$FZF" --ansi --delimiter=$'\t' --with-nth=2 \
  --no-sort --reverse --prompt="move '${wname}' to> " --header-lines=1 \
  --header="enter: move   esc: cancel" \
  --preview="$preview" \
  --preview-window='down,8,wrap')" || exit 0

dest="$(printf '%s' "$sel" | cut -f1)"
[ -z "$dest" ] && exit 0                       # a group header row

if [ "$dest" = "$NEW_ROW_ID" ]; then
  suggestion="$("$here/dirlabel.sh" "$wpath")"
  printf '\n  new session name [%s]: ' "$suggestion"
  IFS= read -r name || exit 0
  name="${name:-$suggestion}"
  name="$(printf '%s' "$name" | tr ':.' '--')"        # tmux dislikes these
  [ -z "$name" ] && exit 0
  if "$TMUX_BIN" has-session -t "=$name" 2>/dev/null; then
    "$TMUX_BIN" display-message "session '$name' already exists"
    exit 0
  fi
  # A new session always comes with a window; kill that placeholder once the
  # real window has landed beside it.
  "$TMUX_BIN" new-session -d -s "$name" -c "$wpath"
  placeholder="$("$TMUX_BIN" list-windows -t "$name:" -F '#{window_id}')"
  "$here/window-park.sh" move "$name" "${wins[@]}"
  "$TMUX_BIN" kill-window -t "$placeholder" 2>/dev/null || true
  "$TMUX_BIN" move-window -r -t "$name:" 2>/dev/null || true
  exit 0
fi

"$here/window-park.sh" move "$dest" "${wins[@]}"
