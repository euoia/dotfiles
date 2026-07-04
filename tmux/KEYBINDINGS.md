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

## Panes

| Key | Effect |
|-----|--------|
| `⌘h` `⌘j` `⌘k` `⌘l` | Move between panes (← ↓ ↑ →) |
| `⇧⌘h` `⇧⌘j` `⇧⌘k` `⇧⌘l` | New split (← ↓ ↑ →) |
| `⌘z` | Zoom / unzoom pane |
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
| `prefix ‹key›` (any) | `0x01` + key's hex (e.g. reorder `0x01 0x67`) |

> `⌥⏎` must stay **unmapped** so it inserts a newline in Claude prompts.
