export ZSH=$HOME/.oh-my-zsh

export TERM='xterm-256color'

KEYTIMEOUT=100

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
bindkey -M emacs '^[[H' beginning-of-line
bindkey -M emacs '^[[F' end-of-line
bindkey -M viins '^[[H' beginning-of-line
bindkey -M viins '^[[F' end-of-line
bindkey -M vicmd '^[[H' vi-beginning-of-line
bindkey -M vicmd '^[[F' vi-end-of-line

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="/opt/node/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin/:/home/jonny/.config/node-version"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
