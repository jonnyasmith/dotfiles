# Verification

`mise run check` is the gate. CI runs the same command. Add a check by adding a
`[tasks."check:*"]` task; the glob picks it up on both sides.

| command | covers |
|---|---|
| `mise run check:config` | every `mise*.toml` parses, including ones this OS never loads |
| `mise run check:shell` | `zsh -n` / `bash -n`, then `shellcheck -S warning` on `bootstrap.sh` |
| `mise run check:packages` | registry rule and apt/dnf/pacman parity in `[bootstrap.packages]` |
| `mise run check:tasks` | `mise tasks validate` |
| `mise run check:dconf` | `desktop/*.dconf` paths exist in installed schemas |
| `./bootstrap.sh --status` / `--dry-run` | local only, never CI |

A check may not require a converged machine, sudo, or a package manager.
Anything that does belongs in `setup:*` — which is why `--dry-run` is not in the
gate.

## Traps

- `check:shell` exits 0 when shellcheck is absent. It is in `[tools]`; run
  `mise install`. Tell: ~70ms when skipped, ~800ms when it lints.
- CI is Linux, so no job ever loads `mise.macos.toml` or `mise.windows.toml`.
  `check:config` parsing them is the only signal they get.
- CI passes `--skip-tools`; local runs do not.
- `mise fmt` has no `--check` mode and rewrites every file it loads. Never a
  gate; own commit or none.
- A nested `mise` inside a task inherits `MISE_CONFIG_ROOT=$HOME` and loads
  only `config.toml`, never the platform file. `check:tasks` unsets it; without
  that, `[tasks.bootstrap]`'s `setup:*` glob reports "task not found".
- `check:packages` takes ~1s because it shells out to `mise search` per entry.
  It is the only check with a dependency beyond python and zsh.

## What counts as verified

Claim what you ran. Nothing in the gate proves a package installs, a repo is
reachable, or a `setup:*` task works on its target distro.
