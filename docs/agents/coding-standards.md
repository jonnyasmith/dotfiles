# Coding standards

- **One mechanism per job.** If mise has a declarative section for it, use that
  rather than a shell step beside it. `[shell_alias]` is the only exception (no
  nushell/PowerShell support).
- **`[tools]` beats a package-manager entry** whenever mise's registry has the
  tool. Check with `mise search -m equal <name>`, and confirm it is the *same
  software* — `code`, `1password` and `tree` all name something else.
- **Pick a `[dotfiles]` mode from two properties**, not one. Whole-directory
  `symlink` is the default; no target currently needs `symlink-each`, so treat a
  new one as a smell until you have shown the writer cannot be relocated.

  | every file ours | another process writes new files there | mode |
  |---|---|---|
  | yes | no | `symlink` (whole directory) |
  | yes | yes, relocatable | relocate it, then `symlink` |
  | yes | yes, not relocatable | `symlink-each` |
  | — | the tool rewrites the file itself | `copy` |

- **Never introduce direnv.** mise owns the environment; upstream does not treat
  the PATH conflict as a bug.
- **Comments carry the failure mode** that motivated the line, or mise behaviour
  that contradicts what you would assume. Nothing else.
- **Conventional Commits**, with the *why* in the body.
