# Coding standards

Read `README.md` before changing anything structural.

- One mechanism per job. If mise has a declarative section for something, use it
  rather than adding a shell step beside it — that is the entire premise of the
  repo. `[shell_alias]` is the documented exception (no nushell/PowerShell
  support).
- Prefer `[tools]` over a package-manager entry whenever mise's registry has the
  tool, so every OS gets one version from one declaration.
- Choose the `[dotfiles]` mode by *who writes the file*: `symlink` when we own
  it, `symlink-each` when the tool writes siblings into the same directory,
  `copy` when the tool rewrites the file itself.
- Never introduce direnv. mise owns the environment; the two conflict over PATH
  and upstream does not treat the incompatibility as a bug.
- Commit with Conventional Commits, and say *why* in the body.

## Comments

The comments in the config files are not decoration: nearly every one records a
failure mode that was hit in practice, and several document mise behaviour that
contradicts what you would assume. Keep that standard — a change that needs an
explanation carries one.
