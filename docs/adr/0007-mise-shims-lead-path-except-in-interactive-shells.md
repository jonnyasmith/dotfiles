# mise shims lead PATH, except in interactive shells

`.zshenv` puts `~/.local/share/mise/shims` at the **front** of PATH, `.zprofile`
re-asserts that after `brew shellenv`, and `.zshrc` demotes the shims to the
tail after `mise activate`. Three files, one ordering; each depends on the other
two.

`mise activate` runs in `.zshrc`, so only interactive shells get it. Git hooks
(husky runs `npx lint-staged` under `sh`), editor- and GUI-spawned shells,
LaunchAgents and cron get none of it — without the shims they see no
`node`/`npx`/`pnpm` at all, and `python3` falls through to `/usr/bin` (Xcode's
3.9) or, once `.zprofile` has run `brew shellenv`, to Homebrew's `python@3.14`.
Those are the two interpreters this repo exists to keep off PATH.

Front, not back: `/usr/bin` and `/opt/homebrew/bin` both ship a `python3`, so an
appended shim loses to them.

Tail in interactive shells: `mise activate` supersedes the shims with the real
install dirs and adds a uv project's `.venv/bin` (`python.uv_venv_auto`). A shim
left in front would sit ahead of that and shadow the project interpreter with
the global one.

## Consequences

- `.zshenv` defines `mise-shims-first` and `mise-shims-last` as functions
  precisely because the ordering is re-asserted from two other files. Editing
  any one of the three without the other two silently changes which `python3` a
  non-interactive shell gets.
- `typeset -U path PATH` in `.zshenv` is load-bearing, not tidiness: vendor
  installers prepend unguarded and a nested shell re-runs every export, so
  without it the re-assertions accumulate duplicates.
- Nothing in `~/.local/bin` shares a name with a shim, so leading shims shadow
  nothing there.
- Verified after the migration: `zsh -c` and `zsh -lc` resolve `python3` to
  `shims/python3`; `zsh -ic` resolves it to `installs/python/3.13/bin/python3`,
  and to `.venv/bin/python` inside a uv project.
