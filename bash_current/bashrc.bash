alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias l="ls -lah --color=auto"
alias la="ls -AF --color=auto"
alias ll="ls -lFh --color=auto"
alias lla="ls -lFha --color=auto"
alias lld="ls -l | grep ^d"
alias rmf="rm -rf --color=auto"

alias desktop="cd /c/users/smithjon/desktop"
alias ppm="cd /d/dev/bitbucket/lth-ppm"
alias epr="cd /d/dev/bitbucket/lth-epr"
alias database="cd /d/dev/bitbucket/lth-database"

alias gitconfig="vim ~/.gitconfig"
alias vimrc="vim ~/.vimrc"
alias bash_profile="vim ~/.bash_profile"
alias bashrc="vim ~/.bashrc"
alias dotfiles="cd ~/.dotfiles"
alias login="cd /d/shared/login && dotnet run"
alias fetch-all="cd /d/dev/bitbucket && find . -mindepth 1 -maxdepth 1 -type d -exec sh -c '(cd {} && echo {} && git fetch)' ';'"

alias h="history"

alias vi=vim
alias edit='vim'

alias reboot='shutdown -r -t 0'
alias shutdown='shutdown -t 0'

alias grep='grep --color=auto'

# source ~/git-complete.bash

SSH_ENV=$HOME/.ssh/environment
DOTFILES=$HOME/.dotfiles
VIM=$HOME/.vim
THEME="peachpuff"
BACKGROUND="dark"
BASE16_SHELL="$DOTFILES/.config/base16-shell/scripts/base16-$THEME-$BACKGROUND.sh"
# source $BASE16_SHELL

# start the ssh-agent
function start_agent {
    echo "Initializing new SSH agent..."
    # spawn ssh-agent
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}

# if [ -f "${SSH_ENV}" ]; then
#      . "${SSH_ENV}" > /dev/null
#      ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
#         start_agent;
#     }
# else
#     start_agent;
# fi

GIT_PROMPT_ONLY_IN_REPO=1  
GIT_PROMPT_FETCH_REMOTE_STATUS=0   #avoid fetching remote status  
GIT_PROMPT_THEME=Single_line_Ubuntu #better theme  
# GIT_PROMPT_IGNORE_STASH=1 #ignore any stashes.  

source ~/.dotfiles/.bash-git-prompt/gitprompt.sh  

todo() {
    git commit --allow-empty -m "TODO: $*"
}
