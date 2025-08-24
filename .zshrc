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

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

export PATH="/opt/node/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin/:/home/jonny/.config/node-version"
