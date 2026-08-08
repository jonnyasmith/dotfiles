# Coding standards

## Traps

- `mise registry` is capped at 1000 rows. Use `mise search -m equal <name>`.
- Registry names that are different software: `code`, `1password` (gives the
  CLI, not the SSH-agent app), `tree` (a Rust reimplementation).
- `config_root` is `$HOME`, not the repo — these configs are read from
  `~/.config/mise`. Hardcode `$HOME/.dotfiles`.
- Precedence between `mise.toml` and `mise.<os>.toml` inverts by route: the
  platform file wins as a project config, the base file wins in the global
  config dir. Keep them key-disjoint.
- `[settings]` is not templated. `dotfiles.root` must be a literal path.
- `auto_env`, `env` and `ceiling_paths` are silently ignored outside
  `.miserc.toml`.
- Task names are global across merged configs. A second `[tasks.bootstrap]`
  replaces the first with no warning.
- Task bodies go through Tera; hook bodies do not. Keep `{{`, `{%` and `{#`
  out of `[tasks.*]`. The third one bites in bash, not Tera: an array length
  ends the run body at `${` + `#`, and the error names a comment tag you never
  wrote. Accumulate into a string instead.
- `[tools]` is the shared desired state; `mise.lock` is per-machine and
  untracked. Never re-link it into the repo or commit one — mise rewrites it on
  every install and upgrade, which is a daily commit on three machines. See
  docs/adr/0011-the-lockfile-is-per-machine.md.
- `mise lock -g --bump` is a local operation now, and still needs `-g`.
  `mise upgrade` holds inside the `minimum_release_age` window, but `--bump`
  re-resolves against the eligible set and rewrites locked versions *downwards*
  — 13 rollbacks observed, including `uv 0.12.1 -> 0.11.32` (2026.7.18). Read
  `--dry-run` first; see
  docs/adr/0006-fuzzy-resolution-is-quarantined-for-seven-days.md.
- mise names the global lockfile after the config *directory*, not the config
  file, and writes *through* the `[dotfiles]` symlink rather than replacing it
  (2026.7.18) — which is what makes a committed lockfile possible.
- Never run `mise bootstrap packages prune --manager brew`. It removes every
  leaf no config declares, and since ADR 0011 no config declares any formula
  at all. Uninstall named formulae instead.
- mise cannot uninstall a cask: there is no `packages remove`, and `prune` is
  formulae-only. Take one back with `brew install --cask --force <token>`,
  which writes the `.metadata/` that marks it Homebrew's; mise's
  `.mise-cask.toml` stays behind as residue.
- Undeclaring a tool leaves its install, shims and copied dotfiles behind;
  convergence never removes them. Uninstall by name — `mise prune` deletes any
  version no tracked config declares, which is wider than what you dropped.
- `[dotfiles]` entries take no `os` filter; an `os` key there is ignored
  without warning. Platform-specific targets belong in `mise.<os>.toml`.
- There is no `mise.wsl.toml` or `mise.arch.toml`: `os()` is `linux` under WSL
  and on Arch. Anything imperative that differs must self-guard on a probe.
- `gpg --dearmor` exits 0 on empty stdin and `set -e` only inspects the last
  command in a pipeline, so a failed key fetch writes an empty keyring plus the
  sources file that guards the block — and no re-run repairs it. Dearmour to a
  temp file and size-check it before anything lands in /etc.
- ssh matches later `Host` patterns against the *rewritten* hostname, so a
  `Host github.com` block also matches an alias whose `HostName` is
  `github.com`. Use `Match originalhost`. Verified on OpenSSH 9.9.
- The uv and rustup installers append `$HOME`-expanded absolute paths to
  `.zshenv`. Rewrite them as `$HOME` before committing, or the file stops
  stowing onto any machine.

## Rules

- `setup:*` may only exit 0. `mise.linux.toml` loads on every Linux, so a task
  that cannot run must skip. Only `check:*` may fail the run.
- Probe with `command -v X >/dev/null 2>&1`. Guard every mutation so a second
  run is a no-op.
- Adding a `mise.<os>.toml` means adding two `[dotfiles]` links.
- `depends` takes a glob, never a literal task name.
- Prefer `[tools]` over a package-manager entry.
- Never introduce direnv.
- Task output: two spaces, one symbol, one space. `.` no-op, `!` problem, `+`
  changed. No emoji, no colour.
- A `[bootstrap.packages]` entry whose name has an exact registry match needs
  `# registry-skip: <reason>`; one declared under exactly two of
  apt/dnf/pacman needs `# parity-skip: <reason>` on every existing entry.
  Waivers are trailing comments, never a separate manifest.
- A nested `mise` inside a task inherits `MISE_CONFIG_ROOT=$HOME` and sees only
  `config.toml`. Unset it before shelling out to `mise`.
- Never pipe a third-party install script into a shell. Add the vendor's
  repository and install the package instead. The two exceptions are both in
  `bootstrap.sh`, and both for the same reason — a fresh machine has no package
  manager that can be relied on to carry them: mise's own installer, and
  Homebrew's on macOS (docs/adr/0011-homebrew-owns-macos-packages.md).
- macOS packages go in the `Brewfile`, never in `[bootstrap.packages]`. mise's
  `brew:`/`brew-cask:` backends reimplement Homebrew rather than call it, and
  two writers to `/opt/homebrew` is the ADR 0004 defect.
- A `[bootstrap.repos]` entry under `~/.oh-my-zsh/custom/plugins` and the
  `plugins=()` list in `home/.zshrc` are one declaration in two places; change
  both. Exactly one ZLE syntax highlighter — two fight over the same hooks.
  zsh-autocomplete is absent for a different reason: it has to be sourced
  before `compinit`, which the OPENSPEC region at the top of `.zshrc` has
  already run.
- `check:*` bodies use the standard library only: CI runs the gate with
  `--skip-tools`, so the interpreter may be the system python3.
- Scripts under `home/.config/tmux/scripts/` must run on bash 3.2 (stock
  macOS): no `mapfile`, no associative arrays, no `${var^^}`.
- A comment explains non-obvious local intent and nothing else. Anything that
  binds beyond the line it sits on has a home in the table in
  docs/agents/code-comments.md — read it before writing a comment block.
  `check:comments` enforces the volume half of that; see
  docs/adr/0009-comment-budget-is-a-static-check.md.

## `[dotfiles]` mode

| every file ours | another process writes new files there | mode |
|---|---|---|
| yes | no | `symlink` (whole directory) |
| yes | yes, relocatable | relocate it, then `symlink` |
| yes | yes, not relocatable | `symlink-each` |
| — | the tool replaces the file on write | `copy` |

Whole-directory `symlink` is the default. Nothing currently needs
`symlink-each`. A tool rewriting the file is not on its own a reason for
`copy` — only a write that lands on the link rather than through it is, and
`copy` then costs one-way drift. mise writes through the link to
`mise.lock`, and omp realpaths `~/.omp/agent/config.yml` before its tmp-file
rename; both link. Check before assuming.

## Do not unify

Known inconsistencies. Leave them:

- `~/` in `mise.toml:316` vs `{{env.HOME}}/` in the per-OS `[env]` blocks.
- `set -u` present in 9 of 12 task bodies.
- Silent vs announced skip when a probe fails.
