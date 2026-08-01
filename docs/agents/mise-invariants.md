# mise invariants

Behaviour that contradicts what you would assume. All verified on mise 2026.7.18.

**The repo must be at `~/.dotfiles`.** `[settings]` is not templated, so
`dotfiles.root` is a literal path and tasks hardcode `$HOME/.dotfiles`. Do not
"fix" this with `{{config_root}}` — see below.

**`config_root` is `$HOME`, not the repo, when a config is reached globally.**
These files are linked into `~/.config/mise`, and mise strips the trailing
`.config/mise`. A task that wants the repo must say `$HOME/.dotfiles`.

**Precedence between `mise.toml` and `mise.<os>.toml` inverts by route.** As
project configs the platform file wins (`unix < {os} < {os}-{arch}`); in the
global config dir the base file wins. Merging is unaffected — only collisions
flip, so keep the files key-disjoint.

**Adding a `mise.<os>.toml` means adding two `[dotfiles]` links.** Without the
second it is a project-only file that exists solely while your shell is inside
the repo. `check:config` enforces this.

**Early-init settings** (`auto_env`, `env`, `ceiling_paths`) work only in
`.miserc.toml`. In `mise.toml` they are silently ignored.

**Task names are global across merged configs.** A second `[tasks.bootstrap]`
replaces the shared one with no warning. `check:config` enforces the single
definition; `depends` uses globs (`setup:*`) so a task absent on this platform
is skipped rather than a hard failure.

**Hook bodies are not templated; task bodies are.** `[bootstrap.hooks.*]` `run`
goes straight to `sh`. `[tasks.*]` `run` goes through Tera first — keep `{{` and
`{%` out of it.

**`setup:*` runs on every bootstrap**, and `mise.linux.toml` loads on every
Linux — Arch, Fedora, Debian, WSL alike. Probe (`command -v dnf`) and exit 0
when absent.

**`mise.lock` pins tools, not `[tools]`.** Bump with `mise lock -g --bump` or
`mise upgrade`; `-g` is required. Commit the result.
