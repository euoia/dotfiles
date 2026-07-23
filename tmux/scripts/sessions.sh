#!/usr/bin/env bash
# Popup SESSION switcher — the session-level twin of switcher.sh.
#
# Lists every session grouped ACTIVE / PARKED ("parked" = the @parked session
# option, set by session-park.sh — a label, nothing is detached or hidden), with
# the projects each session actually contains, its window count, how many of its
# windows are waiting on you (bell flag), and how long since it was touched.
# The preview pane shows that session's windows.
#
#   enter    switch to the session
#   ctrl-p   park / un-park the highlighted session (list reloads in place)
#   ctrl-r   auto-name the highlighted session after its directories
#
# Run inside `display-popup -E`. `sessions.sh --list` prints the rows only
# (that's what the in-picker reload calls).
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
self="$here/sessions.sh"

FZF="/opt/homebrew/bin/fzf"; [ -x "$FZF" ] || FZF="fzf"
TMUX_BIN="/opt/homebrew/bin/tmux"; [ -x "$TMUX_BIN" ] || TMUX_BIN="tmux"

DIM=$'\033[2m'; OFF=$'\033[0m'; CYAN=$'\033[36m'; GREEN=$'\033[32m'

# Fields are tab-separated, and tab is an IFS *whitespace* character, so `read`
# collapses runs of them: every field after an EMPTY one shifts left. An empty
# #{session_last_attached} (a session that has never been attached) silently
# turned the parked flag into the timestamp — parked sessions rendered as
# active, dated 20657d. A non-whitespace separator would fix it, except tmux
# escapes control bytes in format output (\x1f comes out as a literal "\037"),
# so instead every field that CAN be empty is emitted with a "." sentinel in
# front, stripped after the read.
SEP=$'\t'

# "3d" / "4h" / "12m" / "now" since an epoch timestamp.
ago() {
  local d=$(( $2 - $1 ))
  if   [ "$d" -lt 90 ];    then printf 'now'
  elif [ "$d" -lt 5400 ];  then printf '%dm' $(( d / 60 ))
  elif [ "$d" -lt 172800 ];then printf '%dh' $(( d / 3600 ))
  else                          printf '%dd' $(( d / 86400 ))
  fi
}

# Truncate to $2 characters with a trailing ellipsis.
clip() {
  if [ "${#1}" -le "$2" ]; then printf '%s' "$1"
  else printf '%s…' "$(printf '%s' "$1" | cut -c1-$(( $2 - 1 )))"
  fi
}

# Distinct project labels of a session's panes, most-used first, up to 3.
labels_for() {
  local out="" label
  while read -r path; do
    [ -z "$path" ] && continue
    label="$("$here/dirlabel.sh" "$path")"
    [ -z "$label" ] && continue
    case " $out " in *" $label "*) continue ;; esac
    out="${out:+$out }$label"
  # NB the trailing colon — list-panes resolves -t as a PANE target, so a bare
  # "1" means window 1 of the CURRENT session, not the session called "1".
  done < <("$TMUX_BIN" list-panes -s -t "$1:" -F '#{pane_current_path}' 2>/dev/null \
             | sort | uniq -c | sort -rn | sed -E 's/^ *[0-9]+ //')
  printf '%s' "$out" | awk '{ n = (NF > 3 ? 3 : NF); s = "";
                              for (i = 1; i <= n; i++) s = s (i > 1 ? " " : "") $i;
                              print s (NF > 3 ? " +" (NF - 3) : "") }'
}

list() {
  local now cur bells rows group_active group_parked
  now="$(date +%s)"
  cur="$("$TMUX_BIN" display-message -p '#{session_name}' 2>/dev/null || true)"
  bells="$("$TMUX_BIN" list-windows -a -f '#{==:#{window_bell_flag},1}' \
             -F '#{session_name}' 2>/dev/null || true)"
  # Last column is "when were you last IN here" (last_attached), NOT
  # session_activity — an agent chugging away in a session you haven't opened
  # for a week keeps session_activity at "now", which is the opposite of what
  # this column is for.
  rows="$("$TMUX_BIN" list-sessions -F "#{session_name}${SEP}#{session_windows}${SEP}.#{session_last_attached}${SEP}#{?@parked,1,0}${SEP}#{session_attached}")"

  group_active=""; group_parked=""
  while IFS="$SEP" read -r name nwin seen parked attached; do
    [ -z "$name" ] && continue
    seen="${seen#.}"                       # drop the empty-field sentinel
    local waiting mark flag line seen_txt
    waiting="$(printf '%s\n' "$bells" | grep -cxF -- "$name" || true)"
    waiting="$(printf '%s' "$waiting" | tr -d ' ')"
    [ "$name" = "$cur" ] && mark="▸" || mark=" "
    # printf -v, not $(...) — command substitution would strip the trailing pad
    # space and shift the last column by one for any session with a flag.
    if [ "$waiting" -gt 0 ] 2>/dev/null; then printf -v flag '⚑%-2s' "$waiting"
    else flag="   "
    fi
    # last_attached is 0 for a session that has never been attached (created
    # detached by a script or restored by resurrect) — without this it renders
    # as "20657d", i.e. epoch.
    if [ "${attached:-0}" -gt 0 ] 2>/dev/null;  then seen_txt="open"
    elif [ -z "$seen" ] || [ "$seen" = "0" ];   then seen_txt="—"
    else                                             seen_txt="$(ago "$seen" "$now")"
    fi
    line="$(printf '%s %-14s %-32s %2sw %s %4s' \
      "$mark" "$(clip "$name" 14)" "$(clip "$(labels_for "$name")" 32)" \
      "$nwin" "$flag" "$seen_txt")"
    if [ "$parked" = "1" ]; then
      group_parked="${group_parked}$(printf '%s\t%s%s%s\n' "$name" "$DIM" "$line" "$OFF")"$'\n'
    elif [ "$name" = "$cur" ]; then
      group_active="${group_active}$(printf '%s\t%s%s%s\n' "$name" "$GREEN" "$line" "$OFF")"$'\n'
    else
      group_active="${group_active}$(printf '%s\t%s%s%s\n' "$name" "$CYAN" "$line" "$OFF")"$'\n'
    fi
  done <<< "$rows"

  # Group headers are rows with an EMPTY id field, so selecting one is a no-op.
  [ -n "$group_active" ] && { printf '\t%s── active ─────%s\n' "$DIM" "$OFF"; printf '%s' "$group_active"; }
  [ -n "$group_parked" ] && { printf '\t%s── parked ─────%s\n' "$DIM" "$OFF"; printf '%s' "$group_parked"; }
  return 0
}

# Sub-commands the in-picker key bindings call back into (they must not print
# to the popup, hence execute-silent + the redirect).
case "${1:-}" in
  --list) list; exit 0 ;;
  park)   [ -n "${2:-}" ] && "$here/session-park.sh" toggle "$2" >/dev/null 2>&1 || true; exit 0 ;;
  rename) [ -n "${2:-}" ] && "$here/session-autoname.sh" "$2" >/dev/null 2>&1 || true; exit 0 ;;
esac

preview="$TMUX_BIN list-windows -t {1}: -F '#{?#{==:#{window_bell_flag},1},⚑ ,  }#{window_index}: #{window_name}   #{pane_title}' 2>/dev/null | cut -c1-200"

sel="$(list | "$FZF" --ansi --delimiter=$'\t' --with-nth=2 \
  --no-sort --reverse --prompt='session> ' \
  --header='enter: switch   ctrl-p: park/unpark   ctrl-r: auto-name' \
  --preview="$preview" --preview-window='down,10,wrap' \
  --bind "ctrl-p:execute-silent('$self' park {1})+reload('$self' --list)" \
  --bind "ctrl-r:execute-silent('$self' rename {1})+reload('$self' --list)")" || exit 0

name="$(printf '%s' "$sel" | cut -f1)"
if [ -n "$name" ]; then                    # empty = a group header row: ignore
  "$TMUX_BIN" switch-client -t "=$name"
fi
exit 0
