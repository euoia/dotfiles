#!/usr/bin/env bash
# Show the keybindings cheatsheet in a pager (glow > bat > less).
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
f="$HOME/.tmux/KEYBINDINGS.md"
if command -v glow >/dev/null 2>&1; then exec glow -p "$f"
elif command -v bat >/dev/null 2>&1; then exec bat --style=plain --paging=always -l md "$f"
else exec less -R "$f"; fi
