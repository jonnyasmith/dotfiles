# Following code is written by Martin Frost and improved by noahdotpy: https://dev.to/frost/fish-style-abbreviations-in-zsh-40aa
# It adds abbreviations from fish into zsh

# declare a list of expandable aliases to fill up later
typeset -a ealiases
ealiases=()

# write a function for adding an alias to the list mentioned above
function abbrev-alias() {
    alias $1
    export $1
    ealiases+=(${1%%\=*})
}

# expand any aliases in the current line buffer
function expand-ealias() {
    if [[ $LBUFFER =~ "\<(${(j:|:)ealiases})\$" ]] && [[ "$LBUFFER" != "\\"* ]]; then
        zle _expand_alias
        zle expand-word
    fi
    zle magic-space
}
zle -N expand-ealias

# Bind the space key to the expand-alias function above, so that space will expand any expandable aliases
# Bindbindkey ' '        expand-ealias
# BindbBindindkey -M isearch ' '      magic-space     # normal space during searches

# A function for expanding any aliases before accepting the line as is and executing the entered commanad
expand-alias-and-accept-line() {
    expand-ealias
    zle .backward-delete-char
    zle .accept-line
}
zle -N accept-line expand-alias-and-accept-line

# Aliases

abbrev-alias bl='brew list'
abbrev-alias bsl='brew services list'
abbrev-alias buu='brew update && brew upgrade'
abbrev-alias lg='lazygit'
abbrev-alias y='yarn'
abbrev-alias ya='yarn add'
abbrev-alias yad='yarn add -D'
abbrev-alias yd='yarn dev'
abbrev-alias yi='yarn install'
abbrev-alias dotw='dotnet watch'
abbrev-alias dot='dotnet'
abbrev-alias t='tmux'
abbrev-alias auu='sudo apt update && sudo apt upgrade -y'
