# tmux plugins — pinning & update policy

These plugins run as shell code in my interactive session, so they are treated
as third-party supply-chain dependencies (same stance as the GitHub Actions
pinning rules in my global CLAUDE.md).

## Pinned versions

Installed via [tpm](https://github.com/tmux-plugins/tpm) under `~/.tmux/plugins/`,
each checked out at a **detached HEAD** on a specific commit SHA. Detached HEAD is
deliberate: it makes tpm's update command (`prefix + U`) fail rather than silently
fast-forward the plugin onto new upstream code.

| Plugin | Pinned SHA | Audited |
|---|---|---|
| tmux-plugins/tpm | `e261deb1b47614eed3400089ce7197dc68acc4eb` | 2026-06-29 |
| tmux-plugins/tmux-resurrect | `cff343cf9e81983d3da0c8562b01616f12e8d548` | 2026-06-29 |
| tmux-plugins/tmux-continuum | `0698e8f4b17d6454c71bf5212895ec055c578da0` | 2026-06-29 |

Audit (2026-06-29): no network egress, no fetch-and-execute, no credential/secret
access, no `sudo`/`crontab`. The powerful-but-opt-in features are all left OFF:
`@continuum-boot` (writes a launchd/systemd auto-start unit), `@resurrect-processes`
(restores non-allowlisted programs via `eval`), and `@resurrect-save-shell-history`
(gdb-attaches to processes). Process restore uses the safe default allowlist only
(editors/pagers), reconstructed from a local save file.

## Do NOT use `prefix + U` (blind update)

The detached HEAD will block it, by design. Updating is a manual, reviewed step.

## How to update a plugin (the only sanctioned path)

1. **Cooldown** — do not adopt any release/commit younger than ~7 days. A hijacked
   release needs time to be caught and yanked. Judge age by the upstream
   release/tag `published_at` (or, lacking releases, the commit's author date on
   the canonical repo), not by anything locally spoofable.
2. **Security-review the diff** before moving the pin:
   ```sh
   cd ~/.tmux/plugins/<plugin>
   /usr/bin/git fetch origin
   /usr/bin/git log --oneline <current-sha>..origin/master
   /usr/bin/git diff <current-sha>..origin/master
   ```
   Read every changed line. Re-run the behavioural scan (network egress,
   fetch-and-exec, secret access, `sudo`/`crontab`, new launchd/systemd writes).
3. **Re-pin** to the reviewed SHA:
   ```sh
   /usr/bin/git -C ~/.tmux/plugins/<plugin> checkout --detach <new-sha>
   ```
4. Update the table above (SHA + audit date) and commit this file.

## Adding a new plugin

Each `set -g @plugin 'owner/repo'` line in `.tmux.conf` is a fresh trust decision:
tpm will clone and source that repo. Audit it first, then pin it the same way.
