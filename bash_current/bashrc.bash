alias g=git
alias ga="git a"
alias gb="git b"
alias gbv="git b -vv"
alias gc="git c"
alias gca="git ca"
alias gcaan="git caan"
alias gco="git co"
alias gd="git d"
alias gf="git f"
alias gl='git l --max-count=20'
alias glg='git lg'
alias gm="git merge --no-ff"
alias gmf="git merge --ff-only"
alias gmt="git mergetool"
alias gp="git pull"
alias gr="git r"
alias greset="git reset"
alias gs="git s -s"
alias gcp="git cherry-pick"
alias gs="git s"
alias gsb="git sb"
alias gst="git stash"
alias mksql='awk '\''NR!=1 && FNR==1{print ""}1'\'' *.sql | awk '\''{sub(/\xef\xbb\xbf/,"");print}'\'' | clip'

source ~/git-complete.bash

__git_complete gb _git_branch
__git_complete gc _git_commit
__git_complete gco _git_checkout
__git_complete gd _git_diff
__git_complete gf _git_fetch
__git_complete g _git
__git_complete gcp _git_cherry_pick
__git_complete gl _git_log
__git_complete glg _git_log
__git_complete gm _git_merge
__git_complete gmf _git_merge
__git_complete gr _git_rebase
__git_complete greset _git_reset
__git_complete gsb _git_show_branch
__git_complete gst _git_stash

SSH_ENV=$HOME/.ssh/environment

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
