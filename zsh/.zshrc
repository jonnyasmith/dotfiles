# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/jonny/.oh-my-zsh/custom/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

export ZSH=$HOME/.oh-my-zsh

export TERM='xterm-256color'
export PATH="/opt/homebrew/opt/python@3.13/libexec/bin:$PATH"

plugins=(    
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
    zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh

for config (~/.config/zsh/*.zsh) source $config

# mise manages node + dotnet SDK versions (replaces nvm and brew dotnet-sdk).
# DOTNET_ROOT, DOTNET_MULTILEVEL_LOOKUP and ~/.dotnet/tools come from
# ~/.config/mise/config.toml, so do not export them here.
eval "$(mise activate zsh)"

source <(fzf --zsh)

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
# Added by Antigravity
export PATH="/Users/jonny/.antigravity/antigravity/bin:$PATH"

# bun completions
[ -s "/Users/jonny/.bun/_bun" ] && source "/Users/jonny/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# opencode
export PATH=/Users/jonny/.opencode/bin:$PATH

bindkey '^ ' autosuggest-accept  # ctrl + space | autosuggest-accept
bindkey '\e' autosuggest-clear  # escape | autosuggest-clear
insert-buffer-newline() {
    LBUFFER+=$'\n'
}
zle -N insert-buffer-newline
bindkey '^[[27;2;13~' insert-buffer-newline

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/jonny/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/Library/pnpm/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/jonny/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
source /Users/jonny/dev/worktree-cli/examples/wrappers/zsh.sh

export PATH="/Users/jonny/dev/devops-cli/bin:$PATH"
