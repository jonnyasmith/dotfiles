# gitconfig
[user]
    name = Jonny Smith
    email = jonny.asmith@gmail.com
[alias]
    # list all aliases
    a = add -A    
    b = branch    
    c = commit
    ca = commit --amend
    caa = commit --amend -a    
    caam = commit --amend -a -m    
    caan = commit --amend -a --no-edit        
    cam = commit -a -m            
    ccp = !sh -c 'git commit -a -m \"$(git rev-parse --abbrev-ref HEAD): ${1}\"' --
    cm = commit -m
    co = checkout
    cob = checkout -b
    cp = cherry-pick
    d = diff
    date=relative --committer='Jonny Smith' --all --since='yesterday'
    dw = diff -w
    f = !git fetch --prune && git s
    ld = diff head^..head --name-status    
	m = merge --no-ff
    mff = merge --ff-only
    mt = mergetool
    p = !git pull && git s
    r = rebase
    rl = reflog
    s = status -s -b
    sb = show-branch
    sb-up = show-branch head @{u}
    sh = show
    standup = log --graph --pretty=format:'%Cred%h%Creset -%s %C(yellow)%d%Creset %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --
    su = !"git log --reverse --branches --since=$(if [[ "Mon" == "$(date +%a)" ]]; then echo "last friday"; else echo "yesterday"; fi) --author=$(git config --get user.email) --format=format:'%C(cyan) %ad %C(yellow)%h %Creset %s %Cgreen%d' --date=local"
    t = tag

    l = log --pretty=format:'%C(bold blue)%h%C(reset) %C(white)%s%C(reset) %C(bold red)%an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit --date=relative
    # show a pretty log graph
    lg = log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) %C(white)%s%C(reset) %C(bold red)%an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)'

    # show what I did today
    day = "!sh -c 'git log --no-merges --format=format:\"%C(bold blue)%h%C(reset) %C(bold red)%an%C(reset) %C(white)%s%C(reset) %C(bold green)(%cd)%C(reset)\" --branches=* --date=relative --after=\"yesterday 11:59PM\" --author=\"`git config --get user.name`\"'"
    # order files by number of commits, ascending
    churn = "!f() { git log --all -M -C --name-only --format='format:' \"$@\" | sort | grep -v '^$' | uniq -c | sort | awk 'BEGIN {print \"count\tfile\"} {print $1 \"\t\" $2}' | sort -g; }; f"

    # show all deleted files in the repo
    deleted = "!git log --diff-filter=D --summary | grep delete"

    # current branch
    cbr = rev-parse --abbrev-ref HEAD

    # submodule shortcuts
	si = submodule init
    su = submodule update
    sub = "!git submodule sync && git submodule update"

	push-up = !sh -c 'git push -u origin \"$(git rev-parse --abbrev-ref HEAD): ${1}\"' --
	push-remote = git push -u origin

	# reset commits
	delete = !git reset --hard HEAD~1 && git s
	delete-up = !git reset --hard @{u} && git s
	undo = !git reset --soft HEAD~1 && git s
	undo-up = !git reset --soft @{u} && git s

    # show number of commits per contributer, sorted
    count = shortlog -sn

    cleanup = "!git remote prune origin && git gc && git clean -df && git stash clear"

    # rebase the current branch with changes from upstream remote
    update = !git fetch upstream && git rebase upstream/`git rev-parse --abbrev-ref HEAD`

    # tag aliases
    # show the last tag
    lt = describe --tags --abbrev=0

    # assume aliases
    assume = update-index --assume-unchanged
    unassume = update-index --no-assume-unchanged
    assumed = "!git ls-files -v | grep ^h | cut -c 3-"
    unassumeall = "!git assumed | xargs git update-index --no-assume-unchanged"

    # grep commands

    # 'diff grep'
    dg = "!sh -c 'git ls-files -m | grep $1 | xargs git diff' -"
    # diff grep changes between two commits
    dgc = "!sh -c 'git ls-files | grep $1 | xargs git diff $2 $3 -- ' -"
    # 'checkout grep'
    cg = "!sh -c 'git ls-files -m | grep $1 | xargs git checkout ' -"
    # add grep
    ag = "!sh -c 'git ls-files -m -o --exclude-standard | grep $1 | xargs git add --all' -"
    # add all
    aa = !git ls-files -d | xargs git rm && git ls-files -m -o --exclude-standard | xargs git add
    # remove grep - Remove found files that are NOT under version control
    rg = "!sh -c 'git ls-files --others --exclude-standard | grep $1 | xargs rm' -"

    # Kaleidoscope commands
    dkal = difftool -y -t Kaleidoscope
    remotes = remote -v

    # check out a local copy of a PR. https://gist.github.com/gnarf/5406589
    pr  = "!f() { git fetch -fu ${2:-origin} refs/pull/$1/head:pr/$1 && git checkout pr/$1; }; f"
    pr-clean = "!git for-each-ref refs/heads/pr/* --format='%(refname)' | while read ref ; do branch=${ref#refs/heads/} ; git branch -D $branch ; done"
[color]
    diff = auto
    status = auto
    branch = auto
    interactive = auto
    ui = auto
[color "branch"]
    current = green bold
    local = green
    remote = red bold
[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old = red bold
    new = green bold
[color "status"]
    added = green bold
    changed = yellow bold
    untracked = red
[color "sh"]
    branch = yellow
[push]
    # push will only do the current branch, not all branches
    default = simple
[branch]
    # set up 'git pull' to rebase instead of merge
    autosetuprebase = always
[diff]
    guitool = p4merge
[merge]
    tool = p4merge
[apply]
    # do not warn about missing whitespace at EOF
    whitespace = nowarn
[core]
    excludesfile = ~/.gitignore_global
    pager = less -FXRS -x2
    editor = vim
    autocrlf = input
[rerere]
    enabled = true
[gitsh]
    defaultCommand = s
[grep]
    extendRegexp = true
    lineNumber = true
[difftool "p4merge"]
    path = C:/Program Files/Perforce/p4merge.exe
    cmd = \"C:/Program Files/Perforce/p4merge.exe\" \"$LOCAL\" \"$REMOTE\"
[mergetool "p4merge"]
    path = C:/Program Files/Perforce/p4merge.exe
    trustexitcode = true
    cmd = \"C:/Program Files/Perforce/p4merge.exe\" \"$BASE\" \"$LOCAL\" \"$REMOTE\" \"$MERGED\"    
[credential]
    helper = wincred
