#!/usr/bin/env bash
#
# Set up a mac from this repo. Safe to re-run: every step checks for its own
# result first, so a second run is a no-op and a partial run can be resumed by
# running it again.
#
#   ./bootstrap.sh              # everything
#   ./bootstrap.sh stow mise    # only the named steps
#   ./bootstrap.sh --list       # what steps exist
#
# Deliberately NOT handled here, because they need a human:
#   - installing Homebrew (needs sudo and an interactive licence prompt)
#   - signing in to 1Password so the SSH agent can auth to GitHub
#   - macOS settings that require a logout (see `defaults` step, applied last)

set -uo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

# ---------------------------------------------------------------- reporting --
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
  BOLD=''; GREEN=''; YELLOW=''; RED=''; DIM=''; RESET=''
fi

STEP_FAILURES=()
say()  { printf '%s\n' "${BOLD}==> $*${RESET}"; }
ok()   { printf '%s\n' "  ${GREEN}✓${RESET} $*"; }
skip() { printf '%s\n' "  ${DIM}·${RESET} ${DIM}$*${RESET}"; }
warn() { printf '%s\n' "  ${YELLOW}!${RESET} $*"; }
die()  { printf '%s\n' "  ${RED}✗${RESET} $*" >&2; STEP_FAILURES+=("$*"); }

have() { command -v "$1" >/dev/null 2>&1; }

# ------------------------------------------------------------------- checks --
step_preflight() {
  say "Preflight"
  [[ "$(uname -s)" == "Darwin" ]] || { die "this script targets macOS"; return 1; }

  if ! have brew; then
    die "Homebrew missing. Install it first, then re-run:"
    printf '%s\n' '      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    return 1
  fi
  ok "Homebrew $(brew --version | head -1 | awk '{print $2}')"

  # Apple silicon puts brew outside the default PATH; make sure login shells see it.
  local shellenv='eval "$(/opt/homebrew/bin/brew shellenv)"'
  if [[ -x /opt/homebrew/bin/brew ]] && ! grep -qF "$shellenv" "$HOME/.zprofile" 2>/dev/null; then
    printf '\n%s\n' "$shellenv" >> "$HOME/.zprofile"
    ok "added brew shellenv to ~/.zprofile"
  else
    skip "brew already on the login PATH"
  fi
}

step_brew() {
  say "Homebrew packages"
  # `brew bundle check` is the cheap idempotence probe; install only if short.
  if brew bundle check --file=Brewfile >/dev/null 2>&1; then
    skip "Brewfile already satisfied"
  else
    brew bundle install --file=Brewfile || { die "brew bundle failed"; return 1; }
    ok "Brewfile applied"
  fi
}

step_omz() {
  say "oh-my-zsh + plugins"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    skip "oh-my-zsh present"
  else
    # Unattended: do not let the installer chsh or launch a nested zsh, and do
    # not let it drop its own .zshrc on top of the one we are about to stow.
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      || { die "oh-my-zsh install failed"; return 1; }
    ok "oh-my-zsh installed"
  fi

  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  mkdir -p "$custom"
  # Keep in sync with the plugins=() list in zsh/.zshrc.
  local repos=(
    "https://github.com/zsh-users/zsh-autosuggestions.git|zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting.git|zsh-syntax-highlighting"
    "https://github.com/zdharma-continuum/fast-syntax-highlighting.git|fast-syntax-highlighting"
    "https://github.com/marlonrichert/zsh-autocomplete.git|zsh-autocomplete"
  )
  local entry url name
  for entry in "${repos[@]}"; do
    url="${entry%%|*}"; name="${entry##*|}"
    if [[ -d "$custom/$name" ]]; then
      skip "$name"
    else
      git clone --depth 1 -q "$url" "$custom/$name" && ok "cloned $name" || die "clone failed: $name"
    fi
  done
}

step_stow() {
  say "Stow packages"
  have stow || { die "stow not installed (should have come from the Brewfile)"; return 1; }

  # oh-my-zsh writes a default ~/.zshrc; stow refuses to clobber a real file.
  if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.pre-stow"
    warn "moved existing ~/.zshrc to ~/.zshrc.pre-stow"
  fi

  # Every top-level dir that is a stow package (has no leading dot, is not .git).
  local pkgs=() d
  for d in */; do
    d="${d%/}"
    [[ "$d" == .* ]] && continue
    pkgs+=("$d")
  done

  local failed=0 p
  for p in "${pkgs[@]}"; do
    if stow --restow --target="$HOME" "$p" 2>/dev/null; then
      ok "$p"
    else
      # Re-run verbosely so the conflicting path is visible, rather than silent.
      warn "$p conflicts:"
      stow --restow --target="$HOME" --verbose "$p" 2>&1 | sed 's/^/      /' | head -6
      failed=1
    fi
  done
  (( failed )) && die "one or more packages failed to stow"
  return 0
}

step_tpm() {
  say "tmux plugin manager"
  local tpm="$HOME/.config/tmux/plugins/tpm"
  if [[ -d "$tpm" ]]; then
    skip "tpm present"
  else
    mkdir -p "$(dirname "$tpm")"
    git clone --depth 1 -q https://github.com/tmux-plugins/tpm "$tpm" \
      && ok "tpm cloned (run prefix + I inside tmux to fetch plugins)" \
      || die "tpm clone failed"
  fi
}

step_mise() {
  say "Dev tools (mise)"
  have mise || { die "mise not installed (should have come from the Brewfile)"; return 1; }

  # dotnet 8 and 10 race over one shared copy of Microsoft's install script, so
  # the first pass can lose one SDK to a Permission denied. A second pass fixes
  # it; this is upstream, not a config problem.
  if ! mise install --yes 2>&1 | sed 's/^/      /'; then
    warn "first pass failed (likely the dotnet install-script race) — retrying"
    mise install --yes 2>&1 | sed 's/^/      /' || { die "mise install failed twice"; return 1; }
  fi
  ok "mise tools installed"

  if have dotnet; then
    # Global .NET tools live in ~/.dotnet/tools, outside any SDK, so mise does
    # not track them and they must be installed separately.
    if dotnet tool list --global 2>/dev/null | grep -q '^ilspycmd'; then
      skip "ilspycmd"
    else
      dotnet tool install --global ilspycmd >/dev/null 2>&1 && ok "ilspycmd" || warn "ilspycmd install failed"
    fi
  fi
}

step_vscode() {
  say "VS Code extensions"
  local list="$DOTFILES/Brewfile.vscode"
  [[ -f "$list" ]] || { skip "no Brewfile.vscode"; return 0; }
  if ! have code; then
    warn "'code' CLI not on PATH — open VS Code and run 'Shell Command: Install code command in PATH'"
    return 0
  fi

  local installed want n=0
  installed="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')"
  while read -r want; do
    want="${want#vscode \"}"; want="${want%\"}"
    [[ -z "$want" ]] && continue
    if ! grep -qxF "$(printf '%s' "$want" | tr '[:upper:]' '[:lower:]')" <<<"$installed"; then
      code --install-extension "$want" --force >/dev/null 2>&1 && ((n++))
    fi
  done < "$list"
  (( n )) && ok "installed $n extension(s)" || skip "all extensions present"
}

step_defaults() {
  say "macOS defaults"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  defaults write com.apple.finder WarnOnEmptyTrash -bool false
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  ok "written"
  killall Finder >/dev/null 2>&1 || true
  killall Dock   >/dev/null 2>&1 || true
  ok "restarted Finder and Dock"
}

# --------------------------------------------------------------------- main --
STEPS=(preflight brew omz stow tpm mise vscode defaults)

if [[ "${1:-}" == "--list" ]]; then
  printf '%s\n' "${STEPS[@]}"
  exit 0
fi

# Named steps run in the order given; otherwise run the standard sequence.
if (( $# )); then
  for s in "$@"; do
    if ! printf '%s\n' "${STEPS[@]}" | grep -qx "$s"; then
      printf 'unknown step: %s (try --list)\n' "$s" >&2
      exit 2
    fi
  done
  TO_RUN=("$@")
else
  TO_RUN=("${STEPS[@]}")
fi

for s in "${TO_RUN[@]}"; do
  "step_$s"
  printf '\n'
done

if (( ${#STEP_FAILURES[@]} )); then
  printf '%s\n' "${RED}${BOLD}Finished with ${#STEP_FAILURES[@]} problem(s):${RESET}"
  printf '  - %s\n' "${STEP_FAILURES[@]}"
  printf '\nFix the above and re-run ./bootstrap.sh — completed steps will be skipped.\n'
  exit 1
fi

printf '%s\n' "${GREEN}${BOLD}Done.${RESET} Start a new shell to pick up the environment:"
printf '  exec zsh\n'
