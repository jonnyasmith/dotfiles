# The lockfile is per-machine and untracked

`mise.lock` is not in this repo. `[dotfiles]` does not link it, `.gitignore`
denies it, and each machine keeps its own at `~/.config/mise/mise.lock`.

It was tracked until now, on the reasoning that `[tools]` holds ranges and only
a lockfile records what those ranges resolved to. That reasoning is sound and
the cost still sank it: mise rewrites the lockfile on *every* install and
upgrade, not on a deliberate `mise lock --bump`. Across three machines updated
daily, a shared lockfile is a daily commit — on the office laptop, then the
home one, each a pull request for a file no human reads. Reformats happen twice
a year. Optimising the twice-a-year case at the expense of the daily one is the
wrong way round, and the failure mode is not a bad commit but a skipped one:
the update happens anyway and the tracked file silently no longer describes any
machine.

Untracking keeps everything the lockfile does *locally* — checksum
verification on download, stable versions between upgrades, no re-resolution on
a plain install. What it gives up is the shared half.

## Consequences

- **Machines drift by design.** Two laptops upgraded a week apart sit on
  different patch versions. That is the expected state, not a defect, and
  nothing reports it.
- **A reformat resolves from scratch, anonymously.** No lockfile to install
  from, and no `gh` yet to supply a token — it is a `[tools]` entry itself. One
  platform's worth of resolution lands near the 60/hour anonymous limit rather
  than far past it; `mise install` is idempotent, so an hour's wait and a re-run
  finishes it.
- **Version history is gone.** `git log -p mise.lock` no longer answers "what
  moved the day this broke". `mise ls` on the machine in question does.
- **`[tools]` carries the full weight of the shared state.** A selector loose
  enough to resolve differently in ways that matter is now a real problem, where
  before the lockfile absorbed it.
- **The `[dotfiles]` link must not come back.** mise writes *through* that
  symlink rather than replacing it, which is exactly what made a tracked
  lockfile work — and what would silently restore the daily churn.
