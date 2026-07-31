#!/usr/bin/env bash
#
# Bring this machine up to what mise.toml declares.
#
#   ./bootstrap.sh              # converge everything
#   ./bootstrap.sh --dry-run    # show what would change, touch nothing
#   ./bootstrap.sh --status     # what is currently out of sync
#
# This script exists only to solve the chicken-and-egg: mise cannot install
# itself from its own config. Everything else — system packages, git repos,
# dotfiles, macOS defaults, systemd units, the login shell, dev tools, and the
# per-platform setup tasks — is declared in mise.toml and the mise.<os>.toml
# beside it, and applied by `mise bootstrap`. If you are looking for what this
# machine installs, read those files, not this one.
#
# Everything below is idempotent; re-run it any time.
#
# Deliberately NOT handled, because each needs a human at a GUI:
#   - signing in to 1Password and enabling Settings -> Developer -> SSH agent
#   - `prefix + I` inside tmux once, to fetch tmux plugins
#   - the per-OS prerequisites in docs/<os>.md

set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

if [[ -t 1 ]]; then
	BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
else
	BOLD=''; GREEN=''; YELLOW=''; RED=''; RESET=''
fi
say()  { printf '%s\n' "${BOLD}==> $*${RESET}"; }
ok()   { printf '%s\n' "  ${GREEN}✓${RESET} $*"; }
warn() { printf '%s\n' "  ${YELLOW}!${RESET} $*"; }
die()  { printf '%s\n' "  ${RED}✗${RESET} $*" >&2; exit 1; }

MODE=apply
case "${1:-}" in
	--dry-run) MODE=dry ;;
	--status)  MODE=status ;;
	"")        ;;
	*)         die "unknown flag: $1 (use --dry-run or --status)" ;;
esac

# The repo has to live at ~/.dotfiles. [settings] is not templated, so
# `dotfiles.root` in mise.toml is the literal path ~/.dotfiles/home and a clone
# anywhere else would link every dotfile to a directory that does not exist.
say "Preflight"
if [[ "$DOTFILES" != "$HOME/.dotfiles" ]]; then
	die "this repo must be cloned to ~/.dotfiles (found $DOTFILES) — mise.toml's dotfiles.root is a literal path"
fi
ok "repo at ~/.dotfiles"

# mise itself. Its own installer is the only bootstrap dependency; on a fresh
# machine there is no package manager we can rely on being present, and mise's
# brew/apt/dnf/pacman support means we do not need one afterwards.
if command -v mise >/dev/null 2>&1; then
	ok "mise $(mise --version | awk '{print $1}')"
else
	warn "mise not found — installing"
	curl -fsSL https://mise.run | sh || die "mise install failed"
	# The installer drops it here; .zshenv puts it on PATH for later shells.
	export PATH="$HOME/.local/bin:$PATH"
	command -v mise >/dev/null 2>&1 || die "mise still not on PATH after install"
	ok "mise $(mise --version | awk '{print $1}') installed"
fi

# mise refuses to read a config it has not been told to trust. Idempotent.
mise trust --quiet "$DOTFILES" || die "mise trust failed"
ok "config trusted"

# The work org and work email are not in this repo, which is public. Without
# config.local, git silently ignores the missing include and work repos commit
# under the personal identity — a wrong-identity failure with no error, which is
# precisely what the routing exists to prevent. So say so, loudly, every run.
if [[ -f "$HOME/.config/git/config.local" ]]; then
	ok "work git identity configured"
else
	warn "no ~/.config/git/config.local — work repos will commit as $(git config --get user.email 2>/dev/null || echo 'the personal identity')"
	warn "  cp home/.config/git/config.local.example ~/.config/git/config.local  # then edit, and add config.work"
fi
printf '\n'

case "$MODE" in
	status)
		say "Bootstrap status"
		exec mise bootstrap status
		;;
	dry)
		say "Bootstrap (dry run — nothing will change)"
		exec mise bootstrap --dry-run
		;;
esac

say "Bootstrap"
# --yes skips the per-phase confirmation prompts. Package installs on Linux
# still prompt for sudo, which is deliberate and cannot be skipped safely.
if mise bootstrap --yes; then
	printf '\n%s\n' "${GREEN}${BOLD}Done.${RESET} Start a new shell to pick up the environment:"
	printf '  exec zsh\n'
else
	printf '\n'
	die "mise bootstrap failed — fix the above and re-run; completed phases converge and will be skipped"
fi
