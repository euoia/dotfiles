#!/usr/bin/env bash
# Jump to the oldest window needing attention (the one shown on status row 2).
set -euo pipefail
"$(dirname "$0")/attention-line.sh"          # make sure the target is current
target="$(tmux show -gv @attention_target 2>/dev/null || true)"
if [ -n "$target" ]; then
  tmux switch-client -t "$target"
else
  tmux display-message "No windows need attention"
fi
