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

bindkey '^ ' autosuggest-accept  # ctrl + space | autosuggest-accept
bindkey '\e' autosuggest-clear  # escape | autosuggest-clear

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$PATH:/opt/nvim/bin:/opt/zig:/home/jonny/.local/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="/home/jonny/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# wt worktree CLI: auto-cd after a successful create
[ -f ~/dev/worktree-cli/examples/wrappers/zsh.sh ] && source ~/dev/worktree-cli/examples/wrappers/zsh.sh
