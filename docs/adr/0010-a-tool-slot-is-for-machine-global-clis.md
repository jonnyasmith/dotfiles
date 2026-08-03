# A `[tools]` slot is for machine-global CLIs

A tool earns a `[tools]` entry only if it is machine-global by nature: a CLI
invoked from any directory, independent of what project you are standing in.
Anything a project could carry as a dev dependency stays out, and is run through
`npx`, `uvx` or the project's own toolchain at the moment it is needed.

The bar exists because the opposite bar — "something I might want on PATH" — has
no failing case, and nine `npm:` CLIs got in under it before anyone noticed:
`firebase-tools` (per-project), `cline`, `kanban`, `ccstatusline` (per-app), and
five more that were installed on every machine and invoked on none. Each cost a
lockfile entry, a shim, an install to keep current, and a line of the
supply-chain surface that `minimum_release_age` exists to guard.

"Machine-global by nature" is checkable by a reader; "I use it often enough" is
a claim only the author can audit, and only from memory. That is the whole
reason for preferring it.

## Consequences

- The trade-off is real and accepted: you will occasionally `npx` something you
  would rather have had on PATH. That is cheaper than nine tools nobody runs.
- Frequency of use is not the test. A machine-global CLI used twice a year still
  belongs here; a per-project tool used daily still does not.
- Removing a tool is not free — see ADR 0004 for the switch-file rule and
  `docs/agents/domain.md` for residue, the state undeclaring leaves behind.
