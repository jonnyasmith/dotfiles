# One updater per binary

Every binary has exactly one thing entitled to replace it. If `[tools]` declares
a tool, mise owns updating it and the vendor's own updater is switched off. If a
vendor updates its software better than mise can, mise does not declare it and
this repo says nothing about its version.

This is ADR 0002 applied to versions rather than to extension lists. There the
defect was Settings Sync and `packages/vscode.txt` both converging the same
state, with only one of them noticing a change. Here it is `mise.lock` and a
vendor updater both deciding which build is on PATH — same defect, except the
drift is silent rather than merely stale, because the vendor writes to a path
mise never reads.

Claude Code is the clearest case. mise installs it from
`aqua:anthropics/claude-code` and pins it in `mise.lock`; left alone, Claude
Code's own updater installs into `~/.local/share/claude/versions/` and repoints
`~/.local/bin/claude`. That build is not in the lockfile, never passed
`minimum_release_age`, and does not appear in `mise ls`. The two owners never
conflict loudly — the vendor simply wins, because it writes last. `bun upgrade`
and `omp update` were the same hazard; both had a comment telling the reader not
to run them, and a comment is not an owner.

The half of this that is not obvious: a vendor updater is sometimes the better
owner. Anthropic's `autoUpdatesChannel: "stable"` is roughly a week old **and
skips releases with known major regressions**. `minimum_release_age = "7d"` is
the same delay with no quality signal at all, which is why `mise lock --bump`
was willing to walk uv from 0.12.1 back to 0.11.32. VS Code is the clearer case
still: it ships a two-hour extension-update quarantine whose stated rationale is
supply-chain safety, and it is not declared here beyond installing the editor.
Choosing mise as the owner buys reproducibility and a lockfile; it does not buy
a better cooldown. The choice is per tool, and it gets written down.

## Consequences

- Five tools are mise-owned and have their vendor updater off: `claude`
  (`DISABLE_UPDATES=1`), `codex` (`check_for_update_on_startup = false`),
  `gemini-cli` (`general.enableAutoUpdate` and `enableAutoUpdateNotification`),
  `copilot` (`autoUpdate`), and `omp` (`startup.checkUpdate`).
- Only Claude Code's switch is an environment variable, so it lives in `[env]`.
  `DISABLE_UPDATES` rather than `DISABLE_AUTOUPDATER`: the latter stops only the
  background path and leaves `claude update` able to fork the install. Anthropic
  documents `DISABLE_UPDATES` for distributing "through your own channels",
  which is what mise is here.
- `DISABLE_UPDATES` covers Claude Code's own binary. Plugin auto-updates are a
  separate mechanism (`FORCE_AUTOUPDATE_PLUGINS`) and the docs do not say
  whether `DISABLE_UPDATES` reaches them. Unverified.
- Codex's `check_for_update_on_startup` is undocumented but real: it is present
  in the source and in the MDM `managed_config.toml` layer. It is not a typo
  and must not be "corrected" out of `~/.codex/config.toml`.
- The other four switches are config keys, so `~/.codex/config.toml`,
  `~/.gemini/settings.json`, `~/.copilot/settings.json` and
  `~/.omp/agent/config.yml` are `copy`-mode dotfiles — copy because each is the
  file its own tool rewrites when a setting is changed from inside the CLI.
- Those files carry the update switch and nothing sensitive. Credentials live
  beside them, not in them: `~/.codex/*.sqlite`, `~/.gemini/oauth_creds.json`,
  `~/.omp/agent/agent.db`, and `~/.copilot/config.json` — whose own header reads
  "User settings belong in settings.json. This file is managed automatically."
- `codex` is the least load-bearing of the five: mise installs it to a path its
  `InstallMethod` detection classifies as `Other`, so it currently offers no
  update action at all, only a version notice. That is an accident of its
  detection logic rather than a guarantee, so the switch is set anyway.
- `gemini-cli` is the most load-bearing: its install-method detection falls back
  to "assume global npm", whose remedy is `npm install -g @google/gemini-cli@latest`
  — a shadowing copy outside mise entirely.
- VS Code stays vendor-owned, for the application and its extensions both,
  consistent with ADR 0002. Declaring `update.mode` here would make this repo a
  second owner of something Settings Sync already carries.
- mise's own `self-update` is left enabled. `MISE_SELF_UPDATE_AVAILABLE=false`
  would disable it, but nothing else on the machine can update mise, so the rule
  does not apply: there is no competing owner.
- `bun` and Homebrew need no switch. Neither upgrades anything on its own;
  `bun upgrade` and `brew upgrade` are manual, and `HOMEBREW_NO_AUTO_UPDATE`
  governs only the metadata refresh.
- A tool may not be added to `[tools]` while its own updater is live and
  switchable. Either turn the updater off in the same commit, or leave the tool
  undeclared and let the vendor own it.
