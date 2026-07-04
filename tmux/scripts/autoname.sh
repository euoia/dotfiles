#!/usr/bin/env bash
# Rename a window to a short auto name: <dir-label>:<slug>, where <slug> is a
# kebab-cased 2-3 word summary of Claude's current task (falls back to the git
# branch). Kept short and lowercase to match hand-named windows like
# "greendragon:vue2-to-vue3".
# Arg 1: optional pane id (defaults to the active pane of the current window).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
pane="${1:-$(tmux display -p '#{pane_id}')}"

path="$(tmux display -p -t "$pane" '#{pane_current_path}')"
label="$("$here/dirlabel.sh" "$path")"
title="$(tmux display -p -t "$pane" '#{pane_title}')"

# Lowercase, strip non-alnum to spaces, drop filler words, then grow a
# hyphenated slug word-by-word until it would exceed 20 chars or 3 words.
slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -c 'a-z0-9' ' ' \
    | awk '{
        split("the a an and or of to for on in with into from your my this that is are be",sw," ");
        for (i in sw) drop[sw[i]] = 1;
        s = ""; n = 0;
        for (i = 1; i <= NF; i++) {
          w = $i;
          if (w == "" || (w in drop) || length(w) < 2) continue;
          cand = (n == 0 ? w : s "-" w);
          if (length(cand) > 20) break;
          s = cand; n++;
          if (n >= 3) break;
        }
        print s;
      }'
}

suffix=""
case "$title" in
  /*|"~"*|"$path"|"") suffix="" ;;                  # shell showing a path -> no task
  *) suffix="$(slugify "$title")" ;;
esac

# Fall back to a non-default git branch if there's no Claude task.
if [ -z "$suffix" ]; then
  branch="$(/usr/bin/git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  case "$branch" in main|master|HEAD|"") branch="" ;; esac
  [ -n "$branch" ] && suffix="$(slugify "$branch")"
fi

name="$label"
[ -n "$suffix" ] && name="$label:$suffix"
tmux rename-window -t "$pane" "$name"
