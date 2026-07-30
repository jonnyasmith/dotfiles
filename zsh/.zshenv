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

# mise shims as a PATH *fallback*, so node/npx/pnpm/python resolve in contexts
# that never source .zshrc: git hooks (husky runs `npx lint-staged` under sh),
# editor/GUI-spawned shells, LaunchAgents, cron. Interactive shells are
# unaffected -- `mise activate` in .zshrc runs later and prepends the real
# install dirs, which also apply [env] vars and python.uv_venv_auto that shims
# do not. Appended (not prepended) so it never shadows an explicit tool.
case ":$PATH:" in
	*":$HOME/.local/share/mise/shims:"*) ;;
	*) export PATH="$PATH:$HOME/.local/share/mise/shims" ;;
esac
