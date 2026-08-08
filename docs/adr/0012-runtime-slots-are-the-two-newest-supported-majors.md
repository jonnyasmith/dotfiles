# Runtime slots are the two newest supported majors

A runtime in `[tools]` gets two slots: the current LTS, and the previous LTS
while it is still supported. The newest is first, so it is the default
everywhere no per-repo file says otherwise. A repo that needs something older
declares it — in the version file its ecosystem already uses, or in its own
`mise.local.toml`.

Runtimes only. Registry-backed CLIs stay on `latest` and are governed by
ADR 0010; this is about `dotnet`, `node`, `python` and `pnpm`, where a major is
a compatibility boundary and more than one has to be installed at once.

The rule replaces "whatever the most repos in `~/dev` can tolerate", which
picked the default by surveying checkouts. That is unauditable from the config,
machine-specific — three laptops hold different repos — and it ratchets
downwards: one repo pinned two majors back holds every machine there, and
nothing ever reports the cost. Two newest supported majors is checkable against
the vendor's release calendar by anyone reading the file, and it puts the cost
of falling behind on the repo that fell behind.

## Consequences

- **The default moves on the vendor's schedule, not on the state of `~/dev`.**
  When an LTS ships, the slots shift and repos that cannot follow declare it
  themselves. That is the intended pressure, not a regression.
- **"Supported" is load-bearing, not "latest two".** .NET 8 loses support around
  November 2026 and .NET 12 is a year after that, so the second slot empties
  rather than holding an unsupported runtime for twelve months.
- **CPython has no LTS track**, so it reads as the two newest minors — 3.14 and
  3.13. Dropping 3.12 costs one repo (`commercial-intelligence`, capped
  `>=3.12,<3.13`), which already carries `.python-version` and needs no further
  declaration.
- **The per-repo half only works where mise reads the file.** `.nvmrc`,
  `.node-version`, `.python-version` and `global.json` are honoured;
  `engines.node` in `package.json` (190 in `~/dev`) and `requires-python` in
  `pyproject.toml` are not. For python that gap is covered by uv, which reads
  `requires-python` itself. For node it is not covered by anything, so a repo
  whose only signal is `engines` gets the default and fails at runtime.
- **`pnpm` has no escape hatch at all** — mise ignores `packageManager`. Its two
  slots are the whole story, and a project needing a third major needs a
  `mise.local.toml`.
- **Only the first node slot self-maintains.** `node@lts` tracks the current LTS
  and `node@lts/jod` names one by codename, but there is no relative `lts-1`
  (verified 2026.8.6). Both slots stay literal majors so they read the same way.
- **Undeclaring leaves the install behind.** Dropping a slot does not uninstall
  it; `mise uninstall python@3.12.13` does. See ADR 0004 and
  `docs/agents/domain.md` on residue.
