# The mise floor is a hard `min_version`, capped by winget

`mise.toml` sets `min_version`, and the value is whatever winget's `jdx.mise`
manifest currently supplies — not the newest mise the config was written
against.

A hard floor rather than a warning, because an old mise does not error on a
section it does not know: it ignores `[dotfiles]`, `bootstrap`, auto_env
platform configs and glob `depends` and reports success. A stale binary would
therefore "succeed" with the entire per-OS half of this repo silently skipped,
and a partially-applied bootstrap is worse than a refusal.

Capped by winget because `bootstrap.ps1` installs mise from `jdx.mise`. A floor
above what that manifest ships means bootstrap installs a mise that every
subsequent `mise` invocation refuses, and the Windows box bricks itself at step
two.

## Consequences

- Raising `min_version` requires checking `winget show jdx.mise` first. The
  manifest lagged the upstream release by roughly three days when this was
  written (`2026.7.15` against `2026.7.18`).
- The floor is not the version the behavioural notes in this repo were verified
  on. Those notes name their own version; none of the *features* the config
  depends on arrived after the floor.
- A machine below the floor gets a refusal from mise itself, so no check in
  `mise run check` has to assert it.
