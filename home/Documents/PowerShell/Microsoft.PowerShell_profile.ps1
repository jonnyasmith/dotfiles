# PowerShell profile — managed by ~/.dotfiles, applied by mise [dotfiles].
#
# Target: ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1, i.e. pwsh 7+
# (Microsoft.PowerShell from packages/winget.txt). Windows PowerShell 5.1 reads
# ~\Documents\WindowsPowerShell\ instead and is deliberately left alone.
#
# The zsh equivalent is home/.config/zsh/aliases.zsh + home/.zshrc; this file
# mirrors the parts of it that mean anything on Windows. Modules come from the
# PowerShell Gallery, not from this repo, so every import is guarded — a
# machine that has not run the Install-Module lines in docs/windows.md still
# gets a working shell, just without the extras.

# ------------------------------------------------------------------ helpers --
function Import-IfAvailable {
    param([Parameter(Mandatory)][string]$Name)

    if (Get-Module -Name $Name) { return $true }
    if (-not (Get-Module -ListAvailable -Name $Name)) { return $false }
    Import-Module -Name $Name -ErrorAction SilentlyContinue
    return [bool](Get-Module -Name $Name)
}

function Test-Command {
    param([Parameter(Mandatory)][string]$Name)
    [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

# ----------------------------------------------------------------- runtimes --
# mise owns node/python/dotnet/neovim/starship/fzf and rewrites PATH per
# directory, exactly as `eval "$(mise activate zsh)"` does in home/.zshrc.
# Each of these is the idiom the tool's own docs give for PowerShell.
if (Test-Command 'mise') {
    (& mise activate pwsh) | Out-String | Invoke-Expression
}

# Prompt. home/.config/starship.toml is shared with macOS and Linux.
if (Test-Command 'starship') {
    Invoke-Expression (& starship init powershell)
}

if (Test-Command 'zoxide') {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ------------------------------------------------------------------ modules --
# The three from windows/post-install.ps1 in the old repo. PSFzf only earns its
# keep when the fzf binary is actually there (mise installs it). Ctrl+f rather
# than PSFzf's default Ctrl+t, matching the profile that was on this machine
# before mise.
if ((Test-Command 'fzf') -and (Import-IfAvailable 'PSFzf')) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}
$null = Import-IfAvailable 'Terminal-Icons'
$null = Import-IfAvailable 'z'

# PSReadLine ships with pwsh. Carried over from the profile that was on this
# machine before mise (vi editing, history prediction, menu completion); zsh is
# on the default emacs bindings, so this one deliberately differs.
if (Import-IfAvailable 'PSReadLine') {
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# ------------------------------------------------------------------ aliases --
# PowerShell resolves aliases before functions, so pwsh's built-in gcm
# (Get-Command), gm (Get-Member) and gp (Get-ItemProperty) would shadow the git
# shortcuts below and silently do something else. They are ReadOnly, hence
# -Force; the Alias: drive is used because Remove-Alias does not exist in 5.1.
foreach ($shadow in 'gcm', 'gm', 'gp') {
    if (Test-Path -LiteralPath "Alias:\$shadow") {
        Remove-Item -LiteralPath "Alias:\$shadow" -Force -ErrorAction SilentlyContinue
    }
}

function reload { . $PROFILE }

Set-Alias -Name vim -Value nvim
Set-Alias -Name g   -Value git
Set-Alias -Name y   -Value yarn
Set-Alias -Name h   -Value Get-History

function lg { lazygit @args }
function k  { kubectl @args }
function d  { docker @args }
# zsh has `dc=docker-compose`; compose v1 is gone, so this is the v2 subcommand.
function dc { docker compose @args }

# git shortcuts. The single letters are git aliases from home/.config/git/config
# (a = add -A, cm = commit -m, f = fetch --prune, ...), so they stay in sync
# with macOS and Linux.
function ga   { git a . @args }
function gcm  { git cm @args }
function gf   { git f @args }
function gd   { git d @args }
function gll  { git l -20 @args }
function gm   { git m @args }
function gp   { git p @args }
function gr   { git r @args }
function gs   { git s @args }
function push { git push @args }

function gac {
    git add -A
    git commit -m ($args -join ' ')
}

# `fa` in zsh cd's through ~/dev fetching every clone; -C avoids the cd.
function fa {
    $root = Join-Path $env:USERPROFILE 'dev'
    if (-not (Test-Path -LiteralPath $root)) {
        Write-Warning "no $root"
        return
    }
    Get-ChildItem -LiteralPath $root -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName '.git') } |
        ForEach-Object {
            Write-Host "fetching $($_.Name)" -ForegroundColor Yellow
            git -C $_.FullName fetch --all
        }
}

function clean-orig {
    Get-ChildItem -Recurse -File -Filter '*.orig' | Remove-Item -Force
}

# Filesystem
function ..    { Set-Location '..' }
function ...   { Set-Location '../..' }
function ....  { Set-Location '../../..' }
function ..... { Set-Location '../../../..' }

function ll  { Get-ChildItem @args }
function la  { Get-ChildItem -Force @args }
function lla { Get-ChildItem -Force @args }
function lld { Get-ChildItem -Directory @args }
function rmf { Remove-Item -Recurse -Force @args }

function weather { curl.exe -s 'v2.wttr.in' }

# IP addresses. Same opendns trick as the zsh `ip` alias, via the DnsClient
# module instead of dig.
function ip {
    (Resolve-DnsName -Name 'myip.opendns.com' -Server 'resolver1.opendns.com' -Type A).IPAddress
}
function localip {
    (Get-NetIPAddress -AddressFamily IPv4 |
        Where-Object { $_.InterfaceAlias -notmatch 'Loopback|vEthernet|WSL' }).IPAddress
}
function ips {
    (Get-NetIPAddress -AddressFamily IPv4).IPAddress
}

# Not ported from aliases.zsh, on purpose:
#   auu / nuu       apt + nala — those belong in WSL, see docs/wsl.md
#   buu             Homebrew
#   code            aliased to code-insiders on macOS; Windows installs stable
#   wtc / wtr / wtl  the `worktree` helper they call is not in this repo
#   flush, sniff, httpdump, cleanup, fs, emptytrash, hidedesktop, showdesktop,
#   the GET/HEAD/POST lwp-request loop, and the grep/df/du coreutils wrappers
#                   macOS- or GNU-only, no Windows equivalent worth faking
