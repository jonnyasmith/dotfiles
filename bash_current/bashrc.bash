alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias l="ls -lah"
alias la="ls -AF"
alias ll="ls -lFh"
alias lla="ls -lFha"
alias lld="ls -l | grep ^d"
alias rmf="rm -rf"

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

if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi
