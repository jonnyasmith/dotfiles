# Verification

`mise run check` is the gate. CI runs the same command. Add a check by adding a
`[tasks."check:*"]` task; the glob picks it up on both sides.

| command | covers |
|---|---|
| `mise run check:config` | every `mise*.toml` parses, including ones this OS never loads |
| `mise run check:shell` | `zsh -n` / `bash -n` and `shellcheck -S warning` on `bootstrap.sh` and the zsh files, then on every `[bootstrap.hooks.*].run` and `[tasks.*].run` in every `mise*.toml` |
| `mise run check:packages` | registry rule and apt/dnf/pacman parity in `[bootstrap.packages]` |
| `mise run check:tasks` | `mise tasks validate` |
| `mise run check:fmt` | every `mise*.toml` and `.miserc.toml` is `mise fmt`-clean |
| `mise run check:dconf` | `desktop/*.dconf` paths exist in installed schemas |
| `./bootstrap.sh --status` / `--dry-run` | local only, never CI |

A check may not require a converged machine, sudo, or a package manager.
Anything that does belongs in `setup:*` — which is why `--dry-run` is not in the
gate.

## Traps

- `check:shell` exits 0 when shellcheck is absent, so both passes degrade to a
  syntax check. It is in `[tools]`; run `mise install`.
- `check:shell` reads the embedded bodies out of the TOML itself, so the Linux
  hook bodies are checked from macOS and the macOS ones from CI. Dialect
  follows what mise hands the body to: `sh` for hooks and for tasks with no
  `shell` key, otherwise the one the task names. `setup:windows` is pwsh and is
  reported as skipped, not checked.
- Neither pass sees inside a nested quote. `sudo sh -c '…'` in the Fedora
  branch is one string to shellcheck.
- CI is Linux, so no job ever loads `mise.macos.toml` or `mise.windows.toml`.
  `check:config` parsing them is the only signal they get.
- CI passes `--skip-tools`; local runs do not.
- `mise fmt --check` only inspects the configs the current OS loaded, so it is
  green on a mangled `mise.windows.toml` from a Mac. `check:fmt` compares each
  file against `mise fmt --stdin` instead, which needs no load. `mise fmt` does
  not sort keys despite its `--help`; it only normalises whitespace.
- A nested `mise` inside a task inherits `MISE_CONFIG_ROOT=$HOME` and loads
  only `config.toml`, never the platform file. `check:tasks` unsets it; without
  that, `[tasks.bootstrap]`'s `setup:*` glob reports "task not found".
- `check:packages` takes ~1s because it shells out to `mise search` per entry.
  It and `check:shell` are the only checks with a dependency beyond python.

## What counts as verified

Claim what you ran. Nothing in the gate proves a package installs, a repo is
reachable, or a `setup:*` task works on its target distro.
