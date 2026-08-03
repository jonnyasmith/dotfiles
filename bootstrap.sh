#!/usr/bin/env bash
# Bring this machine up to what mise.toml declares.  # comment-budget-skip: the usage block below is this script's interface
#
#   ./bootstrap.sh              # converge everything
#   ./bootstrap.sh --dry-run    # show what would change, touch nothing
#   ./bootstrap.sh --status     # what is currently out of sync
#
# This script exists only to solve the chicken-and-egg: mise cannot install
# itself from its own config. Everything else is `mise bootstrap`.
#
# Everything below is idempotent; re-run it any time.

set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# `set -e` is deliberately absent (the script reports and continues), so this cd
# has to guard itself: every path below is relative to the repo.
cd "$DOTFILES" || { printf 'cannot cd to %s\n' "$DOTFILES" >&2; exit 1; }

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

say "Preflight"
# A clone elsewhere links every dotfile into a directory that does not exist.
if [[ "$DOTFILES" != "$HOME/.dotfiles" ]]; then
	die "this repo must be cloned to ~/.dotfiles (found $DOTFILES) — mise.toml's dotfiles.root is a literal path"
fi
ok "repo at ~/.dotfiles"

# mise's own installer. The one place this repo pipes a script into a shell:
# a fresh machine has no package manager we can rely on to carry mise.
if command -v mise >/dev/null 2>&1; then
	ok "mise $(mise --version | awk '{print $1}')"
else
	warn "mise not found — installing"
	# The installer below is fetched with curl, and a minimal Debian ships
	# neither it nor the CA bundle it needs. Every other platform this repo
	# targets has curl in the base install.
	if ! command -v curl >/dev/null 2>&1; then
		warn "curl not found — installing it first"
		if command -v apt-get >/dev/null 2>&1; then
			sudo apt-get update && sudo apt-get install -y ca-certificates curl
		elif command -v dnf >/dev/null 2>&1; then
			sudo dnf install -y ca-certificates curl
		elif command -v pacman >/dev/null 2>&1; then
			sudo pacman -Sy --needed --noconfirm ca-certificates curl
		fi
		command -v curl >/dev/null 2>&1 || die "curl is required to install mise, and no known package manager could supply it"
	fi
	curl -fsSL https://mise.run | sh || die "mise install failed"
	# The installer drops it here; .zshenv puts it on PATH for later shells.
	export PATH="$HOME/.local/bin:$PATH"
	command -v mise >/dev/null 2>&1 || die "mise still not on PATH after install"
	ok "mise $(mise --version | awk '{print $1}') installed"
fi

# mise refuses to read a config it has not been told to trust. Idempotent.
mise trust --quiet "$DOTFILES" || die "mise trust failed"
ok "config trusted"

# config.local is not in this public repo. Without it git silently ignores the
# missing include and work repos commit under the personal identity.
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
# --yes skips the per-phase prompts; Linux package installs still ask for sudo.
if mise bootstrap --yes; then
	printf '\n%s\n' "${GREEN}${BOLD}Done.${RESET} Start a new shell to pick up the environment:"
	printf '  exec zsh\n'
else
	printf '\n'
	die "mise bootstrap failed — fix the above and re-run; completed phases converge and will be skipped"
fi
