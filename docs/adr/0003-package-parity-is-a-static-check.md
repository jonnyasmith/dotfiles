# Package placement and parity are enforced by a check, not by eye

`check:packages` asserts two properties of `[bootstrap.packages]` and fails
`mise run check` — the same task CI runs — when either is violated:

1. **Registry rule.** A system package whose name has an exact `mise search -m
   equal` match belongs in `[tools]`, where every OS gets one locked version.
2. **Parity.** A package name declared under two of `apt`/`dnf`/`pacman` but not
   the third is drift.

Waivers are `# registry-skip: <reason>` and `# parity-skip: <reason>` comments
beside the entry, so the reason lives where the decision is visible instead of
in a separate manifest that goes stale.

Both rules already existed as prose and neither was applied: ten registry-
covered CLIs were still declared per-OS, and Fedora was missing five packages
every other distro had.

## Consequences

- The check shells out to `mise search`, making it the first check with a
  runtime dependency beyond python and zsh. It stays offline-safe otherwise —
  no package manager, no sudo, no converged machine.
- `mise registry` is unusable here: it caps output at 1000 rows and silently
  truncates.
- Homebrew casks are out of scope for both halves. A cask is a GUI application,
  so an identically named registry entry is a different vendor's CLI every time
  (`1password`, `claude` and `codex` all collide today), and parity against a
  Linux distro is meaningless.
- Parity checks names present under **exactly two** managers, not the literal
  "every entry needs two counterparts". The literal rule needed a waiver on
  roughly 48 of 70 entries, because Arch's list is largely hardware and desktop
  packages with no counterpart by construction — and a check that is mostly
  waivers stops being read. Two-of-three catches the failure that actually
  happens (added on one distro, forgotten on another) with nine waivers.
- Three registry names are permanently waived because the entry is different
  software: `code` (a coding CLI, not VS Code), `1password` (the CLI, not the
  desktop app that serves the SSH agent) and `tree` (a Rust reimplementation
  with different flags).
