#!/usr/bin/env bash
# Mark a session as PARKED (or un-park it). "Parked" is purely a label — a
# session-scoped user option `@parked` — that the session picker groups on and
# session-cycle.sh skips. Nothing is detached, killed, or hidden.
#
#   session-park.sh [toggle|park|unpark] [session]
#
# Default: toggle the current session.
set -euo pipefail

mode="${1:-toggle}"
sess="${2:-$(tmux display-message -p '#{session_name}')}"
# NB the trailing colon on every target. `set-option -t 2` resolves "2" as
# *window* 2 of the current session and silently sets the option on the WRONG
# session; "2:" forces a session lookup. ("=2" is no good either — set-option
# rejects it and show-options quietly returns nothing for it.)

is_parked() {
  [ "$(tmux show-options -t "$sess:" -qv @parked 2>/dev/null || true)" = "1" ]
}

case "$mode" in
  toggle) is_parked && mode=unpark || mode=park ;;
esac

case "$mode" in
  park)
    tmux set-option -t "$sess:" @parked 1
    tmux display-message "session '$sess' parked"
    ;;
  unpark)
    tmux set-option -t "$sess:" -u @parked 2>/dev/null || true
    tmux display-message "session '$sess' active"
    ;;
  *)
    echo "usage: session-park.sh [toggle|park|unpark] [session]" >&2
    exit 2
    ;;
esac
