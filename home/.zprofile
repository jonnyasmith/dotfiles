# Sourced by LOGIN zsh only, after .zshenv and before .zshrc. This is where
# Homebrew's PATH comes from, which is why it has to be stowed rather than left
# as whatever `brew` and OrbStack appended on this particular machine: both
# prepend to PATH, so the file that runs them owns tool precedence.

# Homebrew. Apple Silicon first, Intel second, Linuxbrew third, guarded so a
# machine without brew still gets a working login shell — and that is the
# normal case now. Nothing in this repo installs Homebrew: bootstrap.sh
# installs mise and nothing else, and mise's [bootstrap.packages] drives its
# own built-in brew implementation, which does not need the real thing.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
	[ -x "$_brew" ] && eval "$("$_brew" shellenv)" && break
done
unset _brew

# OrbStack CLI integration (docker, orb). Added by OrbStack originally.
source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :

# brew shellenv just prepended /opt/homebrew/bin, which carries a `python3`
# (python@3.14 arrives as a dependency of platformio and is
# upgraded whenever those are). Put the shims back in front so a non-interactive
# login shell — VS Code resolving its environment, anything it then spawns —
# gets mise's Python and Node rather than brew's. Defined in .zshenv.
mise-shims-first
