# reload zsh config
alias reload='source ~/.zshrc'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi

alias vim="nvim"

alias g="git"
alias y="yarn"
alias h="history"
alias clean-orig="find . -name '*.orig' -delete"

alias buu="brew update && brew upgrade"

alias ga='git a .'
alias gcm='git cm'
alias gf='git f'
alias gd='git d'
alias gll='git l -20'
alias gm='git m'
alias gp='git p'
alias gr='git r'
alias gs='git s'
alias push='git push'

git_fetch_all() {
    original_dir=$(pwd)
    cd ~/dev && for dir in */; do
        if [ -d "$dir/.git" ]; then
            echo ""
            echo "\e[33mfetching $dir\e[0m"
            (cd "$dir" && git fetch --all)
        fi
    done
    cd "$original_dir"
}

alias fa='git_fetch_all'

gac_fn() {
    git add -A
    git commit -m "$*"
}

alias gac='noglob gac_fn'

alias d='docker'
alias dc='docker-compose'
alias k='kubectl'

# Filesystem aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias la="ls -AF ${colorflag}"
alias ll="ls -l"
alias lla="ls -la"
alias lld="ls -l | grep ^d"
alias rmf="rm -rf"

alias weather='curl v2.wttr.in'

# Helpers
alias grep='grep --color=auto'
alias df='df -h' # disk free, in Gigabytes, not bytes
alias du='du -h -c' # calculate disk usage for a folder

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en1"
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Recursively delete `.DS_Store` files
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"

# File size
alias fs="stat -f \"%z bytes\""

# Empty the Trash on all mounted volumes and the main HDD
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; rm -rfv ~/.Trash"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# One of @janmoesen’s ProTip™s
for method in GET HEAD POST PUT DELETE TRACE OPTIONS; do
    alias "$method"="lwp-request -m '$method'"
done
