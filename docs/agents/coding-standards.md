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
- `mise.lock` pins tools, not `[tools]`. Bump with `mise lock -g --bump` (`-g`
  required) and commit it.
- `mise bootstrap packages prune --manager brew` removes `brew:mise` — mise is
  a leaf and no config declares it. Uninstall named formulae instead.

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
- A comment explains non-obvious local intent and nothing else. Anything that
  binds beyond the line it sits on has a home in the table in
  docs/agents/code-comments.md — read it before writing a comment block.

## `[dotfiles]` mode

| every file ours | another process writes new files there | mode |
|---|---|---|
| yes | no | `symlink` (whole directory) |
| yes | yes, relocatable | relocate it, then `symlink` |
| yes | yes, not relocatable | `symlink-each` |
| — | the tool rewrites the file itself | `copy` |

Whole-directory `symlink` is the default. Nothing currently needs
`symlink-each`.

## Do not unify

Known inconsistencies. Leave them:

- `~/` in `mise.toml:316` vs `{{env.HOME}}/` in the per-OS `[env]` blocks.
- `set -u` present in 9 of 12 task bodies.
- Silent vs announced skip when a probe fails.
