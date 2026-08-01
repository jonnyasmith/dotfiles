# Code comments

A comment explains non-obvious local intent. Anything durable goes elsewhere.

## Earns a comment

- What this entry depends on — a package that only resolves because the
  pre-packages hook added a repo first.
- Why the name differs from the obvious one.
- What consumes this.
- Why something is absent, naming it and the reason.
- Why a guard exists — the command is not idempotent, or the previous version
  of this line broke something.
- Upstream behaviour that contradicts assumption, with the version checked.

## Never

- Restate the declaration. `"apt:htop" = "latest"` needs no `# installs htop`.
- Narrate the change being made. That is the commit body.
- Explain anything that binds beyond this line.

## Durable facts

| fact | home |
|---|---|
| why the repo decided something | `docs/adr/` |
| what a term means | `docs/agents/domain.md` |
| a rule a diff is reviewed against | `docs/agents/coding-standards.md` |
| how to prove a change works | `docs/agents/verification.md` |
| how to set a machine up by hand | `docs/<os>.md` |
