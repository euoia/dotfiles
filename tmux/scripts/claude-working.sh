#!/usr/bin/env bash
# Claude Code `UserPromptSubmit` hook: Claude is now working on this window.
# Clear the ready/waiting state so the status bar no longer flags it, and
# refresh the "oldest waiting" status line.
cat >/dev/null   # drain stdin (hook payload unused)
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
  tmux set -w -t "$TMUX_PANE" @claude_state working 2>/dev/null || true
  tmux set -w -t "$TMUX_PANE" -u @claude_msg 2>/dev/null || true
  tmux set -w -t "$TMUX_PANE" -u @claude_since 2>/dev/null || true
  "$(dirname "$0")/attention-line.sh" 2>/dev/null || true
fi
exit 0
