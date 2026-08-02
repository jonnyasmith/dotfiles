# Fuzzy version resolution is quarantined for seven days

`minimum_release_age = "7d"` in `mise.toml`. mise defaults to 24h; the dangerous
window for a package ecosystem is the first hours after publication, when a
hijacked or backdoored release is live and not yet yanked. Roughly half of
`[tools]` is `latest`, so a login that runs `mise upgrade` would otherwise pull
artifacts hours old.

This is a security setting, not a stability one, and it is deliberately global
rather than per-tool: an exception list is a list of tools nobody is waiting a
week to vet.

## Consequences

- Scope is *fuzzy* requests (`latest`, `24`, `3.13`) for backends that publish
  release timestamps — aqua, cargo, github, gitlab, go, npm, pipx and most core
  tools. Explicit pins bypass it and versions with no timestamp are included
  anyway. Only `npm:` and `pipx:` apply it to transitive dependencies.
- `mise upgrade` holds: it reports "All tools are up to date" and warns per tool
  with the date each becomes eligible. Nothing is downgraded.
- `mise lock -g --bump` re-resolves every selector from scratch against the
  *eligible* set, so anything locked inside the window is rewritten **down** to
  the newest release older than the floor. It proposed 13 rollbacks against this
  config, including `uv 0.12.1 -> 0.11.32` and `cmake 4.4.2 -> 4.4.0` (verified
  2026.7.18). Always `--dry-run` that one.
- The cost falls hardest on the AI CLIs (claude, codex, gemini-cli, copilot),
  which ship most days and now land a week late.
- The escape hatch is `minimum_release_age_excludes`, or a per-tool
  `minimum_release_age = "0s"` — exempt a tool by name rather than lowering the
  floor for everything.
