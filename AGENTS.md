# Working in this repo

This is a dotfiles repo whose runbook *is* its config. `mise.toml` and the three
`mise.<os>.toml` files beside it declare the whole machine — packages, repos,
dotfiles, login shell, dev tools, per-OS setup — and `mise bootstrap` converges
it. `bootstrap.sh` exists only to install mise itself.

Read `README.md` before changing anything structural. The comments in the config
files are not decoration: nearly every one records a failure mode that was hit
in practice, and several document mise behaviour that contradicts what you would
assume. Keep that standard — a change that needs an explanation carries one.

## Verify

```sh
mise run check          # everything that does not touch the machine
./bootstrap.sh --dry-run   # what convergence would change
./bootstrap.sh --status    # what is currently out of sync
```

`mise run check` is what CI runs, and it is the whole of what CI runs
(`.github/workflows/check.yml` installs zsh and calls it). Adding a check means
adding a `[tasks."check:*"]` task, not editing the workflow — the glob picks it
up on both sides.

| task | asserts |
|---|---|
| `check:config` | every `mise*.toml` parses (**including the ones this OS never loads**), `dotfiles.root` is absolute, every `[dotfiles]` source exists, exactly one `[tasks.bootstrap]`, every platform config is linked into `~/.config/mise` |
| `check:shell` | `zsh -n` / `bash -n` / shellcheck over the shell files this repo installs |
| `check:tasks` | `mise tasks validate` |
| `check:dconf` | `desktop/*.dconf` section paths exist in installed GSettings schemas |

`mise bootstrap --dry-run` is **not** in `check`: it still executes the `setup:*`
tasks, which touch dnf/apt/systemd. Run it locally, not in CI.

`mise fmt` reformats the config files (comment alignment, array expansion). It is
not enforced, because it rewrites every file it loads and that makes for hostile
diffs mid-change. Run it deliberately, on its own commit.

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
