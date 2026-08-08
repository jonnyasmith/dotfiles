# Homebrew owns macOS packages

macOS declares no `[bootstrap.packages]`. The list is a `Brewfile` at the repo
root, applied by `brew bundle` from `[bootstrap.hooks].pre-packages` in
`mise.macos.toml`.

mise's `brew:` and `brew-cask:` backends are not wrappers around Homebrew — they
are a reimplementation of it. mise installs homebrew/core formulae directly into
the canonical Homebrew prefix, fetching metadata from the formulae.brew.sh API,
resolving the runtime dependency closure, downloading bottles from ghcr.io and
performing the same relocation, code-signing and linking work `brew` does when
pouring one. It never shells out to `brew` to do it. So `/opt/homebrew` gets two
writers, which is exactly the defect ADR 0004 exists to prevent — and here the
rule picks Homebrew, because Homebrew is already installed, already owns every
formula and every cask but one, and is what the wider ecosystem expects.

mise's own docs name the non-goal directly: it is "not a replacement for
`apt`/`brew`/`pacman`" and does not manage desktop applications.

The failure that forced the question: `./bootstrap.sh` aborted at the packages
phase on `brew-cask:1password`, so dotfiles, repos, `[bootstrap.macos.defaults]`
and the `setup:*` fan-out never ran at all.

## Consequences

- Homebrew is installed by `bootstrap.sh`'s Preflight beside mise, because
  `bootstrap.sh` installs mise from `mise.run` and a genuinely clean laptop has
  no `brew` when the packages hook fires. That makes it the second fetched
  script this repo runs, and the coding-standards rule names both.
- `NONINTERACTIVE=1` keeps that install unattended. It still prompts for sudo to
  create `/opt/homebrew`, which is the only human step a clean Mac has — so
  `README.md`'s "there is nothing else" stands and there is no `docs/macos.md`.
- The hook passes no `--cleanup`. Cleanup uninstalls anything absent from the
  Brewfile, which turns a forgotten line into data loss on a daily driver.
  Convergence is not worth that here; the Brewfile adds, and removal is a human
  act (see *residue* in `docs/agents/domain.md`).
- The Brewfile is broader than the 16 casks `[bootstrap.packages]` declared.
  Homebrew already owned eleven this repo never mentioned; the declared and
  undeclared halves only existed because the mise migration's scope forced the
  split, and that reason is gone.
- macOS gains a real upgrade path. `brew upgrade` moves formulae and casks;
  `[bootstrap.packages]` never upgraded anything on any platform, because
  `"latest"` there means latest-at-install-time. apt/dnf/pacman still have that
  gap, and it is not addressed here.
- VS Code and Chrome need no special case. Under mise a lockfile entry would
  desynchronise from their own updaters; Homebrew casks carry no such pin, so
  ADR 0004 leaves them vendor-owned and the Brewfile only installs them.
- `check:packages` is untouched. `brew-cask:` was already out of scope, the
  parity rule covers apt/dnf/pacman only (ADR 0003), and the Brewfile is not a
  `[bootstrap.packages]` table so nothing in the gate reads it. Proving it
  installs needs `brew bundle check --file=Brewfile`, which is a converged
  machine and therefore not a check.
- Only `kitty` physically moved. It was the one mise-owned cask on this machine
  (a `.mise-cask.toml` in the Caskroom, no `.metadata/`); everything else was
  already Homebrew's, including all ten formulae and `mise` itself. Nothing else
  was uninstalled, so 1Password's SSH agent never stopped answering and
  Karabiner-Elements kept its Input Monitoring and system-extension approvals.
- The hand-over runs one way only: Homebrew adopts, mise does not release. mise
  has no cask-uninstall path at all — `mise bootstrap packages` has no `remove`,
  and its `prune` is formulae-only. `brew install --cask --force kitty` writes
  the `.metadata/` that constitutes ownership, over the top of mise's install.
  Both wrote the same 0.48.2 to the same Caskroom directory, so the running
  terminal survived it.
- mise's `.mise-cask.toml` is left behind by that, one directory down from the
  `.metadata/` Homebrew now keeps beside it. Deleting it before this change
  merges would make mise read the cask as missing and try to reinstall it,
  which is the failure being fixed. Homebrew clears the directory on the next
  kitty upgrade.
- `mise` is deliberately absent from the Brewfile. `bootstrap.sh` puts it there
  first, and a `/opt/homebrew` copy would be a second owner of the one binary
  nothing else can update.
