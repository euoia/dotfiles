#!/usr/bin/env bash
# Move windows OUT of a working session into the shared "parked" session, and
# back again. Session-level parking (session-park.sh) labels a whole session;
# this is the per-window version: it FREES A SLOT in a session that has filled
# up, without losing the window.
#
#   window-park.sh [toggle|park|unpark] [window-id …]
#
# No ids = the current window. Parking remembers where a window came from
# (@parked_from), so un-parking puts it back in its own session. Both sessions
# are renumbered afterwards so ⌥1-9 stays dense — that is the point of the
# exercise, but it does mean other windows shift.
set -euo pipefail

PARKED="${TMUX_PARKED_SESSION:-parked}"

mode="${1:-toggle}"
case "$mode" in
  toggle|park|unpark) shift || true ;;
  *) mode="toggle" ;;
esac

# "The current window" must be resolved from $TMUX_PANE, which tmux sets for
# run-shell and hooks. Without -t, `display-message -p` answers for whichever
# client tmux considers current — with two clients attached that can be the
# OTHER terminal, so you'd park a window you can't even see. Same trap that bit
# pane-tall.sh.
here_target=""
[ -n "${TMUX_PANE:-}" ] && here_target="$TMUX_PANE"
ask() { tmux display-message -p ${here_target:+-t "$here_target"} "$1" 2>/dev/null || true; }

wins=("$@")
if [ "${#wins[@]}" -eq 0 ]; then
  wins=("$(ask '#{window_id}')")
fi

# First free window index in a session (respects base-index).
free_index() {
  local last base
  last="$(tmux list-windows -t "$1:" -F '#{window_index}' 2>/dev/null | sort -n | tail -1)"
  if [ -n "$last" ]; then printf '%d' $(( last + 1 ))
  else base="$(tmux show-options -gv base-index 2>/dev/null || true)"; printf '%d' "${base:-0}"
  fi
}

# Create the parked session on demand. A new session always comes with one
# window, so the placeholder is killed once the first real window has moved in.
placeholder=""
ensure_parked() {
  if ! tmux has-session -t "=$PARKED" 2>/dev/null; then
    tmux new-session -d -s "$PARKED" -c "$HOME"
    placeholder="$(tmux list-windows -t "$PARKED:" -F '#{window_id}')"
    tmux set-option -t "$PARKED:" @parked 1        # group it as parked, skip in ( / )
  fi
}

touched=""       # sessions to renumber at the end
note() { case " $touched " in *" $1 "*) ;; *) touched="${touched:+$touched }$1" ;; esac; }

follow=""        # session to follow the window into, if we moved the current one
land_sess=""; land_idx=""      # where to put the cursor after parking the window
                               # you were looking at (see the note below)
current_win="$(ask '#{window_id}')"

parked_count=0; unparked_count=0

for win in "${wins[@]}"; do
  [ -z "$win" ] && continue
  src="$(tmux display-message -p -t "$win" '#{session_name}' 2>/dev/null || true)"
  [ -z "$src" ] && continue

  action="$mode"
  if [ "$action" = "toggle" ]; then
    if [ "$src" = "$PARKED" ]; then action=unpark; else action=park; fi
  fi

  if [ "$action" = "park" ]; then
    [ "$src" = "$PARKED" ] && continue
    # Parking a session's ONLY window destroys that session, which yanks the
    # client somewhere else entirely — it reads as "parking changed my session".
    # Park the whole session instead (prefix P), it stays where it is.
    if [ "$(tmux display-message -p -t "$src:" '#{session_windows}')" -le 1 ]; then
      tmux display-message "'$src' has only this window — park the session instead (prefix P)"
      continue
    fi
    # Where the cursor should land afterwards: the window that takes this one's
    # index once the session is renumbered, i.e. the neighbour to the right,
    # the way closing a tab works.
    if [ "$win" = "$current_win" ]; then
      land_sess="$src"
      land_idx="$(tmux display-message -p -t "$win" '#{window_index}')"
    fi
    ensure_parked
    tmux set-option -w -t "$win" @parked_from "$src"
    tmux move-window -s "$win" -t "$PARKED:$(free_index "$PARKED")"
    note "$src"; note "$PARKED"
    parked_count=$(( parked_count + 1 ))
  else
    [ "$src" != "$PARKED" ] && continue
    # show-WINDOW-options has no -q flag (tmux 3.5a): the error was swallowed by
    # the redirect, this read empty, and windows were "restored" into whatever
    # session happened to be current. Use show-options -w.
    dest="$(tmux show-options -w -t "$win" -qv @parked_from 2>/dev/null || true)"
    if [ -z "$dest" ] || ! tmux has-session -t "=$dest" 2>/dev/null; then
      dest="$(ask '#{session_name}')"                              # the session you're in
    fi
    if [ "$dest" = "$PARKED" ]; then                               # …unless that's parked too
      dest="$(tmux list-sessions -F '#{session_name}' | grep -vxF -- "$PARKED" | head -1)"
    fi
    [ -z "$dest" ] && continue
    tmux move-window -s "$win" -t "$dest:$(free_index "$dest")"
    tmux set-option -w -t "$win" -u @parked_from 2>/dev/null || true
    note "$dest"; note "$PARKED"
    [ "$win" = "$current_win" ] && follow="$dest"
    unparked_count=$(( unparked_count + 1 ))
  fi
done

# The placeholder can only go once a real window is in there beside it.
if [ -n "$placeholder" ]; then
  tmux kill-window -t "$placeholder" 2>/dev/null || true
fi

for s in $touched; do
  tmux has-session -t "=$s" 2>/dev/null && tmux move-window -r -t "$s:" 2>/dev/null || true
done

if [ -n "$follow" ]; then
  tmux switch-client -t "=$follow"
  tmux select-window -t "$current_win"
elif [ -n "$land_sess" ] && tmux has-session -t "=$land_sess" 2>/dev/null; then
  # You parked the window you were looking at, so the client has to show
  # something else. Land on the neighbour rather than wherever tmux chose.
  tmux select-window -t "$land_sess:$land_idx" 2>/dev/null \
    || tmux select-window -t "$land_sess:$(tmux list-windows -t "$land_sess:" -F '#{window_index}' | sort -n | tail -1)" 2>/dev/null \
    || true
fi

if [ "$parked_count" -gt 0 ] && [ "$unparked_count" -gt 0 ]; then
  tmux display-message "parked $parked_count, un-parked $unparked_count"
elif [ "$parked_count" -gt 0 ]; then
  tmux display-message "parked $parked_count → session '$PARKED' — prefix Space to get it back"
elif [ "$unparked_count" -gt 0 ]; then
  tmux display-message "un-parked $unparked_count window(s)"
fi
exit 0
