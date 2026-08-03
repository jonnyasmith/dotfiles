# COSMIC whole-value keys are copied entire

`cosmic-config` resolves a key as one whole value: the user file wins outright
and there is no per-entry merge. Overriding a single entry therefore means
committing the **complete** upstream file.

`desktop/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions` exists
only to point `Terminal` at kitty. It is a full copy of
`/usr/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/system_actions`
because a file containing only `Terminal` would silently drop every other system
action on the machine — brightness, volume, screenshot, lock, log out.

## Consequences

- That file is vendored. Its upstream comments stay byte-comparable to the
  distro default so the two can be diffed; only the `Terminal` value differs.
- It carries a re-sync obligation: a COSMIC upgrade that adds a new system
  action leaves this copy short of it. Re-diff against
  `/usr/share/cosmic/...` after upgrading.
- Tidying it down to the one entry that differs is the failure mode, not the
  cleanup. Any check that measures these files must exclude them.
- The rest of `desktop/cosmic/` is one value per file, so this applies to
  `system_actions` and to any future whole-value key, not to the tree.
