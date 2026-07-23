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
# NB the trailing colon on every target. set-option/show-options resolve -t as a
# PANE target (an option's scope isn't known until it's looked up), so a bare
# "2" means *window 2 of the current session* and the option silently lands on
# the WRONG session. "2:" forces a session lookup. "=2" is no good either —
# set-option rejects it outright and show-options quietly returns nothing (rc 0),
# which would read as "not parked" forever.

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
