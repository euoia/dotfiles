# Keybindings

Keys are what you press. `prefix` = `Ctrl-A`. Popup this with **`prefix i`**.

## Windows

| Key | Effect |
|-----|--------|
| `⌘1`–`9` | Go to window 1–9 |
| `⌥h` / `⌥l` | Previous / next window |
| `⇧⌘C` | New window |
| `⌥a` | Auto-rename window (dir + Claude task) |
| `prefix ,` | Rename window manually |
| `prefix g` / `G` | Group + reorder windows by directory |
| `prefix Space` | Popup switcher (fuzzy, all windows) |
| `prefix p` | Park / un-park this window (move it to the `parked` session) |

In the window switcher: `tab` selects several, `ctrl-p` parks/un-parks them all.
Parking frees a slot in a full session and renumbers what's left, so `⌥1`–`9`
stays dense. Un-parking puts a window back in the session it came from.

## Sessions

Each session is **active** or **parked** — a label only, nothing is hidden or
killed. Parked sessions drop to their own group in the picker and are skipped
by `prefix (` / `)`.

| Key | Effect |
|-----|--------|
| `prefix Tab` | Session picker (grouped active / parked) |
| `prefix )` / `(` | Next / previous **active** session |
| `prefix P` | Park / un-park this session |
| `prefix R` | Auto-name this session after its projects |
| `prefix $` | Rename session manually |

In the picker: `enter` switch · `ctrl-p` park/unpark · `ctrl-r` auto-name.

## Panes

| Key | Effect |
|-----|--------|
| `⌘h` `⌘j` `⌘k` `⌘l` | Move between panes (← ↓ ↑ →) |
| `⇧⌘h` `⇧⌘j` `⇧⌘k` `⇧⌘l` | New split (← ↓ ↑ →) |
| `⌘z` | Zoom / unzoom pane (100%) |
| `⌥m` | Grow pane to 90% height (soft zoom) |
| `prefix =` / `-` | Resize pane up / down |
| `prefix q` / `Q` | Kill pane / window |

## Claude / attention

| Key | Effect |
|-----|--------|
| `⌥0` | Jump to the oldest window waiting for you |
| `⌘⏎` | Submit to Claude + jump to next waiting |
| `prefix a` | Cycle through all waiting windows |
| `prefix e` | Toggle the detailed status row |

## Scroll & copy

| Key | Effect |
|-----|--------|
| `⌥u` / `⌥d` | Half-page up / down |
| `⌥↑` / `⌥↓` | Scroll 5 lines |
| `⌘[` | Enter scroll / copy mode |
| `⌘Home` / `⌘End` | Scroll to top / bottom |
| `⌘/` | Search backward |
| `⌘y` / `⌘p` | Copy to clipboard / paste |

## Help

| Key | Effect |
|-----|--------|
| `prefix i` | This cheatsheet |

---

## Advanced: iTerm2 setup (hex codes)

iTerm2 → Settings → Keys → Key Bindings → action **"Send Hex Code"**.
tmux receives the bytes. **Recipe:** `0x01` (= Ctrl-A prefix) + the key's hex.

| Shortcut | Send Hex |
|----------|----------|
| `⌘1`–`9` | `0x01 0x31` … `0x01 0x39` |
| `⌘h/j/k/l` (panes) | `0x01 0x68/6A/6B/6C` |
| `⇧⌘h/j/k/l` (splits) | `0x01 0x48/4A/4B/4C` |
| `⇧⌘C` (new window) | `0x01 0x63` |
| `⌥h` / `⌥l` (prev/next) | `0x01 0x70` / `0x01 0x6e` |
| `⌥0` (jump waiting) | `0x00` |
| `⌥a` (autoname) | `0x01 0x41` |
| `⌘⏎` (submit + jump) | `0x0d 0x00` |
| `prefix Tab` (sessions) | `0x01 0x09` |
| `prefix ‹key›` (any) | `0x01` + key's hex (e.g. reorder `0x01 0x67`) |

> `⌥⏎` must stay **unmapped** so it inserts a newline in Claude prompts.
