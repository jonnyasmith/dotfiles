
# Install-Module -Name PSFzf -RequiredVersion 2.5.16
# Install-Module -Name Terminal-Icons -Repository PSGallery
# Install-Module z -AllowClobber

Import-Module posh-git
Import-Module DockerCompletion
Import-Module z

# Terminal Icons
Import-Module -Name Terminal-Icons

# PSReadLine
Import-Module -Name PSReadLine
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -Colors @{ InlinePrediction = "#5e5a4b" }
Set-PSReadLineOption -Colors @{ ListPrediction = "#5e5a4b" }
Set-PSReadLineKeyHandler -Chord Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord Ctrl+Spacebar -Function ForwardWord
Set-PSReadLineKeyHandler -Chord Ctrl+n -Function HistorySearchForward
Set-PSReadLineKeyHandler -Chord Ctrl+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Fzf
Import-Module PSFzf
Set-PsFzfOption -PsReadlineChordProvider 'Ctrl+f' -PsReadlineChordReverseHistory 'Ctrl+r'

# Aliases
function upOne { Set-Location ".." }
Set-Alias .. upOne

function upTwo { Set-Location "../.." }
Set-Alias ... upTwo

function upThree { Set-Location "../../.." }
Set-Alias .... upThree

function goToCode { Set-Location "C:/dev" }
Set-Alias dev goToCode

function goHome { Set-Location "~" }
Set-Alias home goHome

Set-Alias l Get-ChildItem | Where-Object { $_.PSIsContainer }
Set-Alias ll ls
Set-Alias vim nvim

function git_status { git s }
Set-Alias -Name gs -Value git_status

function git_fetch { git fetch }
Set-Alias -Name gf -Value git_fetch

function git_add { git add }
Set-Alias -Name ga -Value git_add

Remove-Alias gl -Force

function git_log { git l }
Set-Alias -Name gl -Value git_log

function git_short_log { git ll }
Set-Alias -Name gll -Value git_short_log

Remove-Alias gp -Force

function git_pull { git p }
Set-Alias -Name gp -Value git_pull

function git_push { git push }
Set-Alias -Name push -Value git_push

function touch([string]$file) {
    & New-Item -ItemType file $file
}

function which([string]$command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function Fetch-Repos {
    Set-Location C:\dev
    $folders = Get-ChildItem -Hidden .git -Recurse -Directory -Depth 3
    foreach ($folder in $folders) {
        Write-Host $("`nFetching", $folder.Parent.Name) -ForegroundColor Green
        git -C $folder.Parent.FullName fetch
    }
    Set-Location -
}

Set-Alias -Name fa -Value Fetch-Repos

Set-Alias d docker
function docker_compose_up { docker compose up -d }
Set-Alias -Name dcu -Value docker_compose_up
function docker_compose_down { docker compose down }
Set-Alias -Name dcd -Value docker_compose_down
Set-Alias g git

function git_checkout_branch {
    git checkout @(git branch -r --color=always | grep -v '/HEAD\s' | fzf --height 40% --ansi --multi --tac | sed 's/^..//' | awk '{print $1}' | sed 's#^remotes/[^/]*/##')
}

Set-Alias gcb git_checkout_branch

function Clean-Solution {
    Get-ChildItem bin, obj -Recurse | Remove-Item -Force -Recurse -Verbose
}

Set-Alias -Name cleanSolution -Value Clean-Solution

Invoke-Expression (&starship init powershell)

function GitAddCommit {
    $commitMessage = $args -join ' '
    git add --all
    git commit -m "$commitMessage"
}

Set-Alias -Name gac -Value GitAddCommit

function ?? { 
    $TmpFile = New-TemporaryFile
    github-copilot-cli what-the-shell ('use powershell to ' + $args) --shellout $TmpFile
    if ([System.IO.File]::Exists($TmpFile)) { 
        $TmpFileContents = Get-Content $TmpFile
        if ($TmpFileContents -ne $nill) {
            Invoke-Expression $TmpFileContents
            Remove-Item $TmpFile
        }
    }
}
 
function git? {
    $TmpFile = New-TemporaryFile
    github-copilot-cli git-assist $args --shellout $TmpFile
    if ([System.IO.File]::Exists($TmpFile)) {
        $TmpFileContents = Get-Content $TmpFile
        if ($TmpFileContents -ne $nill) {
            Invoke-Expression $TmpFileContents
            Remove-Item $TmpFile
        }
    }
}
function gh? {
    $TmpFile = New-TemporaryFile
    github-copilot-cli gh-assist $args --shellout $TmpFile
    if ([System.IO.File]::Exists($TmpFile)) {
        $TmpFileContents = Get-Content $TmpFile
        if ($TmpFileContents -ne $nill) {
            Invoke-Expression $TmpFileContents
            Remove-Item $TmpFile
        }
    }
}