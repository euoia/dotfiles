#!/usr/bin/env bash
# Claude Code `Notification` hook.
# - Records @claude_state=ready / @claude_msg / @claude_since on this window so
#   the tmux status bar can surface what each waiting window wants.
# - Shows one enriched macOS banner. Icon varies by notification type; the
#   banner is posted AS iTerm2 (terminal-notifier -sender) so it uses iTerm's
#   icon and has no "Show" button. Falls back to osascript if terminal-notifier
#   is absent. Jump to the window with the C-Space / Option-0 hotkey.
# Reads the hook JSON on stdin.
input="$(cat)"

get() { printf '%s' "$input" | jq -r "$1 // \"\"" 2>/dev/null; }
ntype="$(get '.notification_type')"
msg="$(get '.message')"

title="Claude"; win_id=""
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
  wname="$(tmux display -p -t "$TMUX_PANE" '#{window_name}' 2>/dev/null || true)"
  [ -n "$wname" ] && title="$wname"
  win_id="$(tmux display -p -t "$TMUX_PANE" '#{window_id}' 2>/dev/null || true)"
  tmux set -w -t "$TMUX_PANE" @claude_state ready 2>/dev/null || true
  # Flatten newlines/tabs: @claude_msg is read back with a tab-delimited
  # `-F` format, so an embedded newline/tab would split the record.
  clean_msg="$(printf '%s' "$msg" | tr '\n\r\t' '   ')"
  tmux set -w -t "$TMUX_PANE" @claude_msg "$clean_msg" 2>/dev/null || true
  # Record when this window first went ready (kept until it's worked on again),
  # so the status bar can surface the window that has waited longest.
  [ -z "$(tmux show -w -t "$TMUX_PANE" -v @claude_since 2>/dev/null || true)" ] \
    && tmux set -w -t "$TMUX_PANE" @claude_since "$(date +%s)" 2>/dev/null || true
  "$(dirname "$0")/attention-line.sh" 2>/dev/null || true
fi

# Icon + subtitle vary by notification type so the banner reads at a glance.
icon="🔔"; sub="Claude"
case "$ntype" in
  permission_prompt)   icon="🔐"; sub="Needs permission" ;;
  idle_prompt)         icon="💬"; sub="Waiting for input" ;;
  agent_needs_input)   icon="❓"; sub="Needs input" ;;
  agent_completed)     icon="✅"; sub="Done" ;;
  auth_success)        icon="🔓"; sub="Authenticated" ;;
  elicitation_dialog|elicitation_complete|elicitation_response)
                       icon="📝"; sub="Input requested" ;;
esac

# Enriched banner for attention-worthy notification types only.
case "$ntype" in
  permission_prompt|idle_prompt|agent_needs_input|agent_completed|elicitation_dialog|"") ;;
  *) exit 0 ;;
esac

body="${msg:-Claude needs you}"
TN="/opt/homebrew/bin/terminal-notifier"
if [ -x "$TN" ]; then
  # Post AS iTerm2: nice icon, no "Show" button, click focuses iTerm. -group
  # collapses repeat notifications for the same window instead of stacking.
  "$TN" -title "$icon $title" -subtitle "$sub" -message "$body" \
        -sender com.googlecode.iterm2 ${win_id:+-group "$win_id"} >/dev/null 2>&1
else
  /usr/bin/osascript - "$icon $title" "$sub" "$body" >/dev/null 2>&1 <<'APPLESCRIPT'
on run {theTitle, theSub, theBody}
  display notification theBody with title theTitle subtitle theSub
end run
APPLESCRIPT
fi
exit 0
