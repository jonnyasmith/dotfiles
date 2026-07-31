# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("$HOME/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

export ZSH=$HOME/.oh-my-zsh

export TERM='xterm-256color'

plugins=(    
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
    zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh

for config (~/.config/zsh/*.zsh) source $config

# mise manages node, bun, python, pnpm and the dotnet SDKs (replaces nvm and
# brew dotnet-sdk). DOTNET_ROOT, DOTNET_MULTILEVEL_LOOKUP and ~/.dotnet/tools
# come from ~/.config/mise/config.toml, so do not export them here.
eval "$(mise activate zsh)"

# activate's own dirs now supersede the shims .zshenv put at the front, and must
# outrank them — including any .venv/bin activate adds per directory. Defined in
# .zshenv; interactive shells are the only ones that get this far.
mise-shims-last

# mise completions. compinit has already run (the OPENSPEC block at the top of
# this file), so a _mise written now is not picked up until the next shell —
# hence the manual autoload on the first run. Regenerated in the background
# every start so it never lags a `mise self-update`. The script itself shells
# out to the `usage` CLI, which mise.toml installs as a tool.
#
# This is oh-my-zsh's own plugins/mise logic minus its `mise activate` call,
# which would activate a second time in the wrong place in the ordering above.
_mise_comp="$HOME/.oh-my-zsh/custom/completions/_mise"
if [[ ! -f $_mise_comp ]]; then
	mkdir -p "${_mise_comp:h}"
	mise completion zsh >| "$_mise_comp"
	autoload -Uz _mise
	typeset -g -A _comps
	_comps[mise]=_mise
else
	mise completion zsh >| "$_mise_comp" &|
fi
unset _mise_comp

source <(fzf --zsh)

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
# Optional per-machine tools. Each is guarded: a fresh mac that has not
# installed one yet should not print an error on every shell start.
[ -d "$HOME/.antigravity/antigravity/bin" ] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# bun completions. The runtime comes from mise and BUN_INSTALL/PATH from
# .zshenv, so only the compdefs — which need an interactive shell — live here.
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

bindkey '^ ' autosuggest-accept  # ctrl + space | autosuggest-accept
bindkey '\e' autosuggest-clear  # escape | autosuggest-clear
insert-buffer-newline() {
    LBUFFER+=$'\n'
}
zle -N insert-buffer-newline
bindkey '^[[27;2;13~' insert-buffer-newline

[ -d "$HOME/.lmstudio/bin" ] && export PATH="$PATH:$HOME/.lmstudio/bin"

[ -f "$HOME/dev/worktree-cli/examples/wrappers/zsh.sh" ] && source "$HOME/dev/worktree-cli/examples/wrappers/zsh.sh"
[ -d "$HOME/dev/devops-cli/bin" ] && export PATH="$HOME/dev/devops-cli/bin:$PATH"
