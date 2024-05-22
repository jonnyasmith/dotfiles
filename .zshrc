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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(starship init zsh)"
