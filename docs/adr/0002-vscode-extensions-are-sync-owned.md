# VS Code extensions are owned by Settings Sync

VS Code extensions are *sync-owned*: VS Code Settings Sync converges them from
a GitHub gist, unattended, on every machine signed into the same account. This
repo declares VS Code itself on every platform and declares nothing about its
extensions.

A 104-entry `packages/vscode.txt` and a `setup:vscode` task applied it in
parallel with Settings Sync. Two owners of the same state, and only one of them
noticed an extension installed from inside the editor — so the list rotted the
first time it was bypassed, which is the same day it was written.

## Consequences

- `packages/vscode.txt` and `[tasks."setup:vscode"]` are deleted. Do not
  reintroduce a list; the absence is the decision.
- Convergence handles what only it can — installing the editor — and defers
  what something else does better.
- A machine that is not signed into Settings Sync gets no extensions. That is
  the accepted cost: signing in is one action and it also carries settings,
  keybindings and snippets, which the list never did.
