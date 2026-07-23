#!/usr/bin/env bash
# Popup window switcher: lists every window across all sessions in an fzf
# picker (fuzzy filter, Enter to jump). Meant to be run inside a tmux
# display-popup. Each row shows a bell marker, the tmux location, the window
# name, and a dimmed one-line task; the preview pane shows the full task + cwd.
#
# Windows that live in the "parked" session are grouped at the bottom.
#
#   enter    jump to the window
#   tab      select several (multi-select)
#   ctrl-p   park / un-park the selected window(s) — moves them out of a full
#            session into "parked", or back where they came from
#
# `switcher.sh --list` prints the rows only (what the in-picker reload calls).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
self="$here/switcher.sh"

FZF="/opt/homebrew/bin/fzf"; [ -x "$FZF" ] || FZF="fzf"
TMUX_BIN="/opt/homebrew/bin/tmux"; [ -x "$TMUX_BIN" ] || TMUX_BIN="tmux"
PARKED="${TMUX_PARKED_SESSION:-parked}"

DIM=$'\033[2m'; OFF=$'\033[0m'; CYAN=$'\033[36m'; YELLOW=$'\033[33m'

# Tab is an IFS *whitespace* character, so `read` collapses runs of it and every
# field after an EMPTY one shifts left — an empty #{pane_title} would put the
# cwd in the task column and the session name in the cwd. tmux escapes control
# bytes in format output, so a non-whitespace separator is out; instead the
# empty-able field is emitted with a "." sentinel in front, stripped after read.
SEP=$'\t'

# fzf input: field1 = @id (hidden), field2 = ANSI display, field3 = full task,
# field4 = cwd. Display = mark + location + name + dimmed truncated task.
list() {
  local records active parked
  records="$("$TMUX_BIN" list-windows -a -F "#{window_id}${SEP}#{?#{==:#{window_bell_flag},1},1,0}${SEP}#{session_name}:#{window_index}${SEP}#{window_name}${SEP}.#{pane_title}${SEP}#{pane_current_path}${SEP}#{session_name}")"

  active=""; parked=""
  while IFS="$SEP" read -r id bell loc name task cwd sess; do
    [ -z "$id" ] && continue
    task="${task#.}"                       # drop the empty-field sentinel
    local mark dt row
    if [ "$bell" = "1" ]; then mark="${YELLOW}⚑${OFF} "; else mark="  "; fi
    dt="$task"; [ "${#dt}" -gt 48 ] && dt="${dt:0:48}…"
    if [ "$sess" = "$PARKED" ]; then
      row="$(printf '%s\t%s%s  %s  %s\t%s\t%s' \
        "$id" "$mark" "$DIM$loc" "$name" "$dt$OFF" "$task" "$cwd")"
      parked="${parked}${row}"$'\n'
    else
      row="$(printf '%s\t%s%s%s  %s  %s%s%s\t%s\t%s' \
        "$id" "$mark" "$CYAN" "$loc" "$OFF$name" "$DIM" "$dt" "$OFF" "$task" "$cwd")"
      active="${active}${row}"$'\n'
    fi
  done <<< "$records"

  # Group headers carry an EMPTY id, so acting on one is a no-op.
  printf '%s' "$active"
  [ -n "$parked" ] && { printf '\t%s── parked ─────%s\t\t\n' "$DIM" "$OFF"; printf '%s' "$parked"; }
  return 0
}

case "${1:-}" in
  --list) list; exit 0 ;;
  park)   shift; "$here/window-park.sh" toggle "$@" >/dev/null 2>&1 || true; exit 0 ;;
esac

sel="$(list | "$FZF" --ansi --delimiter=$'\t' --with-nth=2 --multi \
  --no-sort --reverse --prompt='window> ' \
  --header='enter: jump   tab: select   ctrl-p: park/un-park' \
  --preview='printf "Task:\n  %s\n\nCwd:\n  %s\n" {3} {4}' \
  --preview-window='down,4,wrap' \
  --bind "ctrl-p:execute-silent('$self' park {+1})+reload('$self' --list)")" || exit 0

id="$(printf '%s' "$sel" | head -1 | cut -f1)"
if [ -n "$id" ]; then
  "$TMUX_BIN" switch-client -t "$id"
fi
exit 0
