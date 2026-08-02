# One updater per binary

Every binary on the machine has exactly one thing entitled to replace it. If
mise declares a tool, mise owns updating it and the vendor's own updater is
switched off. If a tool updates itself better than mise can, mise does not
declare it and this repo says nothing about its version.

This is ADR 0002 applied to versions rather than to extension lists. There the
defect was Settings Sync and `packages/vscode.txt` both converging the same
state, and only one of them noticing a change. Here it is `mise.lock` and a
vendor updater both deciding which build of `claude` is on PATH — with the
same outcome, except the drift is silent instead of merely stale, because the
vendor updater writes to a path mise does not look at.

Claude Code is the concrete case. mise installs it from `aqua:anthropics/claude-code`
and pins it in `mise.lock`; left alone, Claude Code's own updater installs into
`~/.local/share/claude/versions/` and repoints `~/.local/bin/claude`. That build
is not in the lockfile, never passed `minimum_release_age`, and is invisible to
`mise ls`. The two owners do not conflict loudly — the vendor simply wins,
because it writes later. `bun upgrade` was the same hazard and got a comment
telling the reader not to run it; a comment is not an owner.

The half of this that is *not* obvious: a vendor updater is sometimes the better
owner. Anthropic's `autoUpdatesChannel: "stable"` is roughly a week old **and
skips releases with known major regressions**; `minimum_release_age = "7d"` is
the same delay with no quality signal at all, which is why `mise lock --bump`
was willing to walk uv from 0.12.1 back to 0.11.32. VS Code is the clearer
example still — it ships a 2-hour extension-update quarantine whose stated
rationale is supply-chain safety, and it is not declared here beyond installing
the editor. Choosing mise as the owner buys reproducibility and a lockfile; it
does not buy a better cooldown. Make the choice per tool, and write down which
owner won.

Evidence and citations: `docs/supply-chain-updates.md`.

## Consequences

- `DISABLE_UPDATES = "1"` is set in `[env]` in `mise.toml`, not
  `DISABLE_AUTOUPDATER`: the latter stops only the background path and leaves
  `claude update` able to fork the install. Anthropic documents `DISABLE_UPDATES`
  for distributing "through your own channels", which is what mise is here.
- Three tools are declared in `[tools]` with their updaters still live, because
  their switches are not env-settable and the files that hold them
  (`~/.codex/config.toml`, `~/.gemini/settings.json`, `~/.copilot/settings.json`)
  also hold auth state, so linking them wholesale would clobber it. The keys are
  `check_for_update_on_startup = false`, `general.enableAutoUpdate: false`, and
  `"autoUpdate": false`. Adopting them means `copy`-mode entries seeded from an
  example file, the same pattern as `~/.config/git/config.local`.
- `codex` is the least urgent of the three: mise installs it to a path its
  `InstallMethod` detection classifies as `Other`, so it offers no update action
  at all — only a version notice. That is an accident of its detection logic, not
  a guarantee, so it still belongs on the list.
- `gemini-cli` is the most urgent: its install-method fallback is "assume global
  npm", whose remedy is `npm install -g @google/gemini-cli@latest` — a shadowing
  copy outside mise entirely.
- VS Code stays vendor-owned for both the app and its extensions, consistent with
  ADR 0002. Declaring `update.mode` here would make this repo a second owner of
  something Settings Sync already carries.
- A tool may not be added to `[tools]` while its own updater is live and
  switchable. Either turn the updater off or leave the tool undeclared.
