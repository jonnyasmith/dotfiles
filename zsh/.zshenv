# Sourced by EVERY zsh: login, interactive, and `zsh -c`. Only PATH and env
# belong here — nothing that prints, prompts, or needs a terminal. Interactive
# setup (oh-my-zsh, starship, mise activate, aliases) lives in .zshrc.
#
# Keep this file free of absolute paths so it stows onto any machine. The uv and
# rustup installers append their own lines here with $HOME expanded; if one does
# that again, re-write it as $HOME before committing.

# uv installs tools and standalone binaries here.
export PATH="$HOME/.local/bin:$PATH"

# rustup. Guarded: a fresh machine has no cargo until rustup has run, and an
# unguarded `.` on a missing file aborts every zsh -c in the session.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

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
# A function because ordering has to be re-asserted: .zprofile's brew shellenv
# runs after this file and prepends /opt/homebrew/bin, so login shells call it
# again. Interactive shells then get `mise activate` in .zshrc, which prepends
# the real install dirs ahead of the shims and also applies [env] vars and
# python.uv_venv_auto that shims cannot.
mise-shims-first() {
	path=("$HOME/.local/share/mise/shims" ${path:#"$HOME/.local/share/mise/shims"})
	export PATH
}
mise-shims-first
