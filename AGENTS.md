# Working in this repo

## Routing — read only what the task needs, when it needs it

### This context

- Solution-wide vocabulary → docs/agents/domain.md
- System-wide decisions → docs/adr/
- Issue tracker (GitHub Issues on `jonnyasmith/dotfiles`, driven by `gh`) → docs/agents/issue-tracker.md
- Triage labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) → docs/agents/triage-labels.md

This is a dotfiles repo whose runbook *is* its config. `mise.toml` and the three
`mise.<os>.toml` files beside it declare the whole machine — packages, repos,
dotfiles, login shell, dev tools, per-OS setup — and `mise bootstrap` converges
it. `bootstrap.sh` exists only to install mise itself.

Read `README.md` before changing anything structural. The comments in the config
files are not decoration: nearly every one records a failure mode that was hit
in practice, and several document mise behaviour that contradicts what you would
assume. Keep that standard — a change that needs an explanation carries one.

## Verify

Run these in order before every commit. Steps 1–2 are the gate; step 3 is
advisory and needs a real machine.

### 1. Format — only when you changed a `mise*.toml`

```sh
mise fmt          # comment alignment, array expansion
```

**Not enforced, and deliberately not part of `check`.** `mise fmt` has no
`--check` mode, and it rewrites every file it loads — running it mid-change
buries your diff in realignment. Run it on its own commit, or not at all.

### 2. Lint and check — always

```sh
mise run check    # parses, lints and asserts; touches nothing
```

This is the gate. It must exit 0 before you commit. It is also **the whole of
what CI runs** (`.github/workflows/check.yml` installs zsh plus shellcheck and
calls it), so a green run here means a green run there.

Adding a check means adding a `[tasks."check:*"]` task, never editing the
workflow — the `check:*` glob picks it up on both sides.

| task | asserts |
|---|---|
| `check:config` | every `mise*.toml` parses (**including the ones this OS never loads**), `dotfiles.root` is absolute, every `[dotfiles]` source exists, exactly one `[tasks.bootstrap]`, every platform config is linked into `~/.config/mise` |
| `check:shell` | `zsh -n` / `bash -n` over the shell files this repo installs, then `shellcheck -S warning` on `bootstrap.sh` |
| `check:tasks` | `mise tasks validate` |
| `check:dconf` | `desktop/*.dconf` section paths exist in installed GSettings schemas |

Every check must run without a converged machine, network access to a package
manager, or sudo — that is what lets CI and your shell run the identical
command. A check that needs any of those belongs in `setup:*`, not here.

**`shellcheck` is in `[tools]`.** If `check:shell` reports it missing, run
`mise install` — do not treat the skip as a pass. It was once optional, which
meant the lint ran in CI and silently no-opped locally.

### 3. Preview convergence — before changing packages, dotfiles or tasks

```sh
./bootstrap.sh --status     # what is currently out of sync
./bootstrap.sh --dry-run    # what convergence would change
```

Advisory, not a gate, and **never in CI**: `mise bootstrap --dry-run` still
executes the `setup:*` tasks, which touch dnf/apt/systemd. Local only.

Some things no static check can reach — that a symlink resolves, a service
starts, a package exists in a distro's repos. Those are verified by converging
a real machine and looking, which is why Arch and Windows are best-effort.

## Rules that are easy to get wrong

**The repo must be at `~/.dotfiles`.** `[settings]` is not templated, so
`dotfiles.root` is a literal path and tasks hardcode `$HOME/.dotfiles`.
`bootstrap.sh` refuses to run anywhere else and CI symlinks the checkout into
place. Do not "fix" this with `{{config_root}}` — see below.

**`config_root` is not the repo when the config is reached globally.** These
files are linked into `~/.config/mise`, and for a config there mise strips the
trailing `.config/mise` and resolves `config_root` to `$HOME`. A task that wants
the repo must say `$HOME/.dotfiles`.

**Platform files must stay key-disjoint with `mise.toml`.** Precedence between
them inverts depending on how they were reached: as project configs the platform
file wins (the documented `unix < {os} < {os}-{arch}` order), but in the global
config dir the base file wins. Verified on mise 2026.7.18. Merging is unaffected;
only collisions flip, so do not create collisions.

**Adding a `mise.<os>.toml` means adding two `[dotfiles]` links** — the config
itself and nothing else works globally without it. `check:config` enforces this.

**Early-init settings** (`auto_env`, `env`, `ceiling_paths`) only work in
`.miserc.toml`, never in `mise.toml`, where they are silently ignored.

**Task names are global across merged configs.** A second `[tasks.bootstrap]` in
a platform file replaces the shared one with no warning. `check:config` enforces
the single definition; `depends` uses globs (`setup:*`) so a task absent on this
platform is skipped rather than a hard failure.

**Hook bodies are not templated; task bodies are.** `[bootstrap.hooks.*]` `run`
goes straight to `sh`, so shell syntax is unrestricted. `[tasks.*]` `run` goes
through Tera first — keep `{{` and `{%` out of it.

**Everything imperative must be idempotent and self-guarding.** `setup:*` runs on
every bootstrap, and `mise.linux.toml` loads on every Linux — Arch, Fedora,
Debian, WSL alike — so probe for what you need (`command -v dnf`) and exit 0
cleanly when it is absent.

**Tools are pinned by `mise.lock`, not by `[tools]`.** Bump with
`mise lock -g --bump` or `mise upgrade`; `-g` is required. Commit the result.

## Conventions

- One mechanism per job. If mise has a declarative section for something, use it
  rather than adding a shell step beside it — that is the entire premise of the
  repo. `[shell_alias]` is the documented exception (no nushell/PowerShell
  support).
- Prefer `[tools]` over a package-manager entry whenever mise's registry has the
  tool, so every OS gets one version from one declaration.
- Choose the `[dotfiles]` mode by *who writes the file*: `symlink` when we own
  it, `symlink-each` when the tool writes siblings into the same directory,
  `copy` when the tool rewrites the file itself.
- Never introduce direnv. mise owns the environment; the two conflict over PATH
  and upstream does not treat the incompatibility as a bug.
- Commit with Conventional Commits, and say *why* in the body.
