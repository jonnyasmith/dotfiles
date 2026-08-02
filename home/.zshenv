# Sourced by EVERY zsh: login, interactive, and `zsh -c`. Only PATH and env
# belong here — nothing that prints, prompts, or needs a terminal. Interactive
# setup (oh-my-zsh, starship, mise activate, aliases) lives in .zshrc.
#
# Keep this file free of absolute paths so it stows onto any machine. The uv and
# rustup installers append their own lines here with $HOME expanded; if one does
# that again, re-write it as $HOME before committing.

# Keep PATH free of duplicates, first occurrence winning. Vendor installers
# prepend unguarded (bun's put ~/.bun/bin on PATH three times over nested
# shells; a stale brew python@3.13 dir was in there twice), and a nested shell
# re-runs every export below. This makes that idempotent instead of cumulative,
# and keeps `mise activate` re-prepending cheap.
typeset -U path PATH

# uv installs tools and standalone binaries here.
export PATH="$HOME/.local/bin:$PATH"

# rustup. Guarded: a fresh machine has no cargo until rustup has run, and an
# unguarded `.` on a missing file aborts every zsh -c in the session.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# bun. BUN_INSTALL is bun's *global package* dir, not the runtime: `bun install
# -g` links binaries into $BUN_INSTALL/bin, so this stays on PATH even though
# mise owns the `bun` binary itself. Was in .zshrc, which meant
# no bun in git hooks or any non-interactive shell, and the installer's
# unguarded prepend put this dir on PATH three times per nested shell.
export BUN_INSTALL="$HOME/.bun"
path=("$BUN_INSTALL/bin" ${path:#"$BUN_INSTALL/bin"})
export PATH

# mise shims, for the contexts that never source .zshrc and so never run `mise
# activate`: git hooks (husky runs `npx lint-staged` under sh), editor/GUI
# spawned shells, LaunchAgents, cron. Without them those see no node/npx/pnpm
# at all, and `python3` falls through to /usr/bin (Xcode's 3.9) or, once
# .zprofile has run brew shellenv, to Homebrew's python@3.14 — the two
# interpreters mise/config.toml exists to keep off PATH.
#
# FRONT of PATH, not the back: /usr/bin and /opt/homebrew/bin both ship a
# `python3`, so an appended shim loses to them. Nothing in ~/.local/bin shares a
# name with a shim (`ls ~/.local/share/mise/shims`), so this shadows nothing.
#
# Functions because the ordering has to be re-asserted twice more:
#   .zprofile  — brew shellenv prepends /opt/homebrew/bin after this file runs,
#                so login shells call mise-shims-first again.
#   .zshrc     — `mise activate` supersedes the shims entirely, and its dirs
#                must win: a shim ahead of them would also sit ahead of a uv
#                .venv/bin that activate adds (python.uv_venv_auto), shadowing
#                the project interpreter with the global one. So interactive
#                shells demote the shims to a harmless tail entry.
mise-shims-first() {
	path=("$HOME/.local/share/mise/shims" ${path:#"$HOME/.local/share/mise/shims"})
	export PATH
}
mise-shims-last() {
	path=(${path:#"$HOME/.local/share/mise/shims"} "$HOME/.local/share/mise/shims")
	export PATH
}
mise-shims-first
