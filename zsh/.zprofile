# Sourced by LOGIN zsh only, after .zshenv and before .zshrc. This is where
# Homebrew's PATH comes from, which is why it has to be stowed rather than left
# as whatever `brew` and OrbStack appended on this particular machine: both
# prepend to PATH, so the file that runs them owns tool precedence.

# Homebrew. Apple Silicon first, Intel second, guarded so a machine without brew
# yet (bootstrap.sh installs it) still gets a working login shell.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
	[ -x "$_brew" ] && eval "$("$_brew" shellenv)" && break
done
unset _brew

# OrbStack CLI integration (docker, orb). Added by OrbStack originally.
source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :

# brew shellenv just prepended /opt/homebrew/bin, which carries a `python3`
# (python@3.14 arrives as a dependency of azure-cli/pipx/platformio and is
# upgraded whenever those are). Put the shims back in front so a non-interactive
# login shell — VS Code resolving its environment, anything it then spawns —
# gets mise's Python and Node rather than brew's. Defined in .zshenv.
mise-shims-first
