#!/usr/bin/env bash
# Toggle the expanded (3rd) status row that lists each waiting window's message.
set -euo pipefail
cur="$(tmux show -gv @statusdetail 2>/dev/null || echo 0)"
if [ "$cur" = "1" ]; then
  tmux set -g @statusdetail 0
  tmux set -g status 2
else
  tmux set -g @statusdetail 1
  tmux set -g status 3
fi
