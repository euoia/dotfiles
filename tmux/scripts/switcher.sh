#!/usr/bin/env bash
# Popup window switcher: lists every window across all sessions in an fzf
# picker (fuzzy filter, Enter to jump). Meant to be run inside a tmux
# display-popup. Each row shows a bell marker, the tmux location, the window
# name, and a dimmed one-line task; the preview pane shows the full task + cwd.
set -euo pipefail

FZF="/opt/homebrew/bin/fzf"; [ -x "$FZF" ] || FZF="fzf"
TMUX_BIN="/opt/homebrew/bin/tmux"; [ -x "$TMUX_BIN" ] || TMUX_BIN="tmux"

# Tab-delimited records: id, bell, location, name, task, cwd.
records="$("$TMUX_BIN" list-windows -a -F \
  '#{window_id}	#{?#{==:#{window_bell_flag},1},1,0}	#{session_name}:#{window_index}	#{window_name}	#{pane_title}	#{pane_current_path}')"

# fzf input: field1 = @id (hidden), field2 = ANSI display, field3 = full task,
# field4 = cwd. Display = mark + location + name + dimmed truncated task.
build() {
  while IFS=$'\t' read -r id bell loc name task cwd; do
    [ -z "$id" ] && continue
    if [ "$bell" = "1" ]; then mark=$'\033[33m⚑\033[0m '; else mark="  "; fi
    dt="$task"; [ "${#dt}" -gt 48 ] && dt="${dt:0:48}…"
    printf '%s\t%s\033[36m%s\033[0m  %s  \033[2m%s\033[0m\t%s\t%s\n' \
      "$id" "$mark" "$loc" "$name" "$dt" "$task" "$cwd"
  done <<< "$records"
}

sel="$(build | "$FZF" --ansi --delimiter=$'\t' --with-nth=2 \
  --no-sort --reverse --prompt='window> ' \
  --preview='printf "Task:\n  %s\n\nCwd:\n  %s\n" {3} {4}' \
  --preview-window='down,4,wrap')" || exit 0

id="$(printf '%s' "$sel" | cut -f1)"
[ -n "$id" ] && "$TMUX_BIN" switch-client -t "$id"
