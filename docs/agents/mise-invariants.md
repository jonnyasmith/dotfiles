# mise invariants — rules that are easy to get wrong

This is a dotfiles repo whose runbook *is* its config. `mise.toml` and the three
`mise.<os>.toml` files beside it declare the whole machine — packages, repos,
dotfiles, login shell, dev tools, per-OS setup — and `mise bootstrap` converges
it. `bootstrap.sh` exists only to install mise itself.

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
