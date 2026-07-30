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

source <(fzf --zsh)

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
# Optional per-machine tools. Each is guarded: a fresh mac that has not
# installed one yet should not print an error on every shell start.
[ -d "$HOME/.antigravity/antigravity/bin" ] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# bun completions. The runtime comes from mise and BUN_INSTALL/PATH from
# .zshenv, so only the compdefs — which need an interactive shell — live here.
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

[ -d "$HOME/.opencode/bin" ] && export PATH="$HOME/.opencode/bin:$PATH"

bindkey '^ ' autosuggest-accept  # ctrl + space | autosuggest-accept
bindkey '\e' autosuggest-clear  # escape | autosuggest-clear
insert-buffer-newline() {
    LBUFFER+=$'\n'
}
zle -N insert-buffer-newline
bindkey '^[[27;2;13~' insert-buffer-newline

[ -d "$HOME/.lmstudio/bin" ] && export PATH="$PATH:$HOME/.lmstudio/bin"

# pnpm's own global bin dir (`pnpm add -g` installs shims here: wt, pn, pnpx).
# Distinct from the pnpm binary itself, which mise owns.
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

[ -f "$HOME/dev/worktree-cli/examples/wrappers/zsh.sh" ] && source "$HOME/dev/worktree-cli/examples/wrappers/zsh.sh"
[ -d "$HOME/dev/devops-cli/bin" ] && export PATH="$HOME/dev/devops-cli/bin:$PATH"
