# Vendor installers prepend unguarded and a nested shell re-runs every export
# below, so keep PATH de-duplicated with the first occurrence winning.
typeset -U path PATH

# uv installs tools and standalone binaries here.
export PATH="$HOME/.local/bin:$PATH"

# rustup. Guarded: a fresh machine has no cargo until rustup has run, and an
# unguarded `.` on a missing file aborts every zsh -c in the session.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# BUN_INSTALL is bun's global *package* dir, not the runtime: mise owns the
# `bun` binary, but `bun install -g` still links into $BUN_INSTALL/bin.
export BUN_INSTALL="$HOME/.bun"
path=("$BUN_INSTALL/bin" ${path:#"$BUN_INSTALL/bin"})
export PATH

# Re-asserted from .zprofile and .zshrc; the three orderings depend on each
# other — docs/adr/0007-mise-shims-lead-path-except-in-interactive-shells.md.
mise-shims-first() {
	path=("$HOME/.local/share/mise/shims" ${path:#"$HOME/.local/share/mise/shims"})
	export PATH
}
mise-shims-last() {
	path=(${path:#"$HOME/.local/share/mise/shims"} "$HOME/.local/share/mise/shims")
	export PATH
}
mise-shims-first
