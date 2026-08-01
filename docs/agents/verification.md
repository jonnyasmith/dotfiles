# Verification

```sh
mise fmt                 # 1. only if you changed a mise*.toml; advisory
mise run check           # 2. the gate — must exit 0 before you commit
./bootstrap.sh --status  # 3. what is out of sync    ) local only,
./bootstrap.sh --dry-run #    what would change      ) never CI
```

`mise run check` is what CI runs and the whole of what CI runs. Adding a check
means adding a `[tasks."check:*"]` task, not editing the workflow — the glob
picks it up on both sides. A check may not need a converged machine, sudo, or a
package manager; anything that does belongs in `setup:*`. That is why
`bootstrap.sh --dry-run` is step 3 and not part of `check`: it executes the
`setup:*` tasks, which touch dnf/apt/systemd.

| task | asserts |
|---|---|
| `check:config` | every `mise*.toml` parses (**including the ones this OS never loads**), `dotfiles.root` is absolute, every `[dotfiles]` source exists, exactly one `[tasks.bootstrap]`, every platform config is linked into `~/.config/mise` |
| `check:shell` | `zsh -n` / `bash -n` over the shell files this repo installs, then `shellcheck -S warning` on `bootstrap.sh` |
| `check:tasks` | `mise tasks validate` |
| `check:dconf` | `desktop/*.dconf` section paths exist in installed GSettings schemas |

`mise fmt` is not enforced: it has no `--check` mode and rewrites every file it
loads, so it gets its own commit or none. `shellcheck` is in `[tools]` — if
`check:shell` says it is missing, run `mise install`; do not read the skip as a
pass.
