# Link whole directories, relocate foreign writers

`[dotfiles]` mode is chosen by two independent properties — whether this repo
is the source of truth for a file's content (*owned file*), and whether some
other process creates *new* files in the same directory (*foreign writer*) —
rather than by one overloaded notion of ownership. Whole-directory `symlink` is
the default; a foreign writer that configuration can point elsewhere is
relocated rather than worked around.

The old rule was "`symlink` when we own it, `symlink-each` when the tool writes
siblings". For `~/.config/nvim` both halves were true at once, so the rule gave
two answers and the wrong one was picked: 19 individual file symlinks, and a
file added to the repo did not exist in `$HOME` until the machine was converged
again.

## Consequences

- No target requires `symlink-each` any more. The mode stays documented in
  `mise.toml` so it is not reintroduced as a default; a surviving entry is a
  mistake.
- tpm moved to `~/.local/share/tmux/plugins` via `TMUX_PLUGIN_MANAGER_PATH`,
  which is what let `~/.config/tmux` become one link.
- herdr cannot be relocated, so its entry names the single file we own rather
  than the directory holding six files herdr writes.
- nvim's `spell/` and `.netrwhist` cannot be relocated per-directory either,
  but they are scratch: they now land inside the working tree and the matching
  `.gitignore` entries became load-bearing rather than defensive.
- On Windows this is strictly better — a file symlink needs elevation and mise
  falls back to copying, but a directory becomes a junction.
