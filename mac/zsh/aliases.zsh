# reload zsh config
alias reload='source ~/.zshrc'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi

# alias vim="nvim"

# Git aliases
alias g="git"                                       # Shortcut for git
alias y="yarn"                                      # Shortcut for yarn
alias h="history"                                   # Shortcut for history
alias clean-orig="find . -name '*.orig' -delete"    # Delete all .orig files

alias ga='git add .'                                # Add all changes
alias gcm='git commit -m'                           # Commit changes with a message
alias gf='git fetch'                                # Fetch changes
alias gl='git log -20'                              # Show last 20 logs
alias gm='git merge'                                # Merge changes
alias gp='git pull'                                 # Pull changes
alias gr='git rebase'                               # Rebase changes
alias gs='git status'                               # Show status
alias push='git push'                               # Push changes

# Filesystem aliases
alias ..='cd ..'                                    # Go up one directory
alias ...='cd ../..'                                # Go up two directories
alias ....="cd ../../.."                            # Go up three directories
alias .....="cd ../../../.."                        # Go up four directories

# ls aliases
alias l="ls -lah ${colorflag}"                      # List all files in long format, including hidden files, with human-readable sizes
alias la="ls -AF ${colorflag}"                      # List all files, including directory entries without trailing slashes
alias ll="ls -lFh ${colorflag}"                     # List all files in long format with human-readable sizes
alias lla="ls -lFha ${colorflag}"                   # List all files in long format, including hidden files, with human-readable sizes
alias lld="ls -l | grep ^d"                         # List only directories
alias rmf="rm -rf"                                  # Remove files or directories forcefully

# Helpers
alias grep='grep --color=auto'
alias df='df -h'                                    # disk free, in Gigabytes, not bytes
alias du='du -h -c'                                 # calculate disk usage for a folder

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