#Requires -Version 5.1
<#
.SYNOPSIS
    Set up a native-Windows machine from this repo. Safe to re-run.

.DESCRIPTION
    The Windows counterpart to ./bootstrap.sh. Every step checks for its own
    result first, so a second run is a no-op and a partial run is resumed by
    running it again. Per item: `+` did something, `.` was already done,
    `!` needs a human, `x` failed (and the run continues).

    This script only does what mise cannot:

      1. winget packages   — mise has no `winget` manager, so [bootstrap.packages]
                             cannot express them. IDs live in packages/winget.txt.
      2. mise itself       — chicken and egg.

    Everything else is mise's: dotfiles come from [dotfiles] in mise.toml /
    mise.windows.toml, and dev tools from [tools]. This script deliberately
    creates no symlinks. Without Developer Mode or elevation mise falls back to
    copying files and to junctions for directories, which is why the Windows
    Terminal settings entry is mode = "copy" anyway.

.PARAMETER Steps
    Run only the named steps, in the order given. Default: all of them.

.PARAMETER List
    Print the step names and exit.

.EXAMPLE
    .\bootstrap.ps1
.EXAMPLE
    .\bootstrap.ps1 winget
.EXAMPLE
    .\bootstrap.ps1 -List

.NOTES
    Deliberately NOT handled here, because they need a human — see
    docs/windows.md: Windows Update, `wsl --install` (elevated, reboots),
    signing in to 1Password so the SSH agent can auth to GitHub, PowerToys
    keyboard remaps, and the power/lid settings in powercfg.cpl.
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Steps,

    [switch]$List
)

Set-StrictMode -Version 3.0
# Cmdlet failures should stop; native tools are judged by exit code instead
# (see Invoke-Native), because a chatty stderr is not a failure.
$ErrorActionPreference = 'Stop'
$global:LASTEXITCODE = 0

$Dotfiles   = $PSScriptRoot
$ConfigFile = Join-Path $Dotfiles 'mise.toml'
$WingetList = Join-Path $Dotfiles 'packages/winget.txt'

# ---------------------------------------------------------------- reporting --
$script:Failures = New-Object System.Collections.Generic.List[string]
$script:Mise     = $null

function Say  { param([string]$Message) Write-Host "==> $Message" -ForegroundColor Cyan }
function Ok   { param([string]$Message) Write-Host "  + $Message" -ForegroundColor Green }
function Skip { param([string]$Message) Write-Host "  . $Message" -ForegroundColor DarkGray }
function Warn { param([string]$Message) Write-Host "  ! $Message" -ForegroundColor Yellow }
function Fail {
    param([string]$Message)
    Write-Host "  x $Message" -ForegroundColor Red
    $script:Failures.Add($Message)
}

function Have {
    param([Parameter(Mandatory)][string]$Name)
    [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

# Run a native tool, indent its output under the step, and hand back its exit
# code. $ErrorActionPreference drops to Continue for the call: with 2>&1 under
# 'Stop', anything a tool writes to stderr surfaces as a terminating
# NativeCommandError and would abort the whole bootstrap over a warning.
function Invoke-Native {
    param(
        [Parameter(Mandatory)][string]$Exe,
        [string[]]$Arguments = @(),
        [switch]$Quiet
    )
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $global:LASTEXITCODE = 0
        if ($Quiet) {
            & $Exe @Arguments 2>&1 | Out-Null
        }
        else {
            & $Exe @Arguments 2>&1 | ForEach-Object { Write-Host "      $_" }
        }
        return $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previous
    }
}

function Update-PathFromEnvironment {
    # winget drops its shims in a directory that a running shell may not have
    # on PATH yet. Re-read the machine and user PATH so a freshly installed
    # mise is callable without opening a new window.
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = (@($machine, $user) | Where-Object { $_ }) -join ';'
}

# ------------------------------------------------------------------ winget --
function Test-WingetInstalled {
    param([Parameter(Mandatory)][string]$Id)

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $global:LASTEXITCODE = 0
        $output = & winget list --id $Id --exact --accept-source-agreements 2>&1 | Out-String
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previous
    }

    # winget returns 0x8A15002B when nothing matches, but some versions exit 0
    # and say so on stdout instead. Matching the ID itself is not reliable — a
    # narrow console truncates the Id column — so match the message.
    if ($code -ne 0) { return $false }
    return ($output -notmatch 'No installed package found')
}

function Install-WingetPackage {
    param([Parameter(Mandatory)][string]$Id)

    $code = Invoke-Native -Exe 'winget' -Arguments @(
        'install', '--id', $Id, '--exact',
        '--silent',
        '--accept-package-agreements',
        '--accept-source-agreements'
    )
    if ($code -eq 0) { return $true }

    # A non-zero exit is not proof of failure: "already installed", "no
    # applicable upgrade" and "reboot required" all report as errors. Ask
    # winget what is actually on the machine before calling it a failure.
    return (Test-WingetInstalled -Id $Id)
}

function Get-WingetIdList {
    param([Parameter(Mandatory)][string]$Path)
    Get-Content -LiteralPath $Path |
        ForEach-Object { ($_ -replace '#.*$', '').Trim() } |
        Where-Object { $_ }
}

# -------------------------------------------------------------------- mise --
function Resolve-Mise {
    $command = Get-Command -Name 'mise' -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($command) { return $command.Source }

    # winget's shim directory, for the run that just installed mise.
    foreach ($candidate in @(
            (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\mise.exe'),
            (Join-Path $env:USERPROFILE '.local\bin\mise.exe')
        )) {
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    return $null
}

function Test-MiseTrusted {
    param([Parameter(Mandatory)][string]$Path)

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $lines = & $script:Mise trust --show 2>&1
    }
    finally {
        $ErrorActionPreference = $previous
    }

    $wanted = $Path.TrimEnd('\', '/')
    foreach ($line in $lines) {
        # "C:\Users\jonny\.dotfiles: trusted" — greedy .+ stops at the last
        # colon, so the drive letter's colon stays in the path.
        if ([string]$line -notmatch '^(?<path>.+):\s*(?<state>\S+)\s*$') { continue }
        $candidate = $Matches['path'].Trim()
        if ($candidate.StartsWith('~')) {
            $candidate = Join-Path $env:USERPROFILE $candidate.Substring(1).TrimStart('/', '\')
        }
        $resolved = Resolve-Path -LiteralPath $candidate -ErrorAction SilentlyContinue
        if (-not $resolved) { continue }
        if ($resolved.ProviderPath.TrimEnd('\', '/') -ieq $wanted) {
            return ($Matches['state'] -eq 'trusted')
        }
    }
    return $false
}

# ------------------------------------------------------------------- steps --
function Step-Preflight {
    Say 'Preflight'

    $onWindows = if ($PSVersionTable.PSVersion.Major -ge 6) { $IsWindows } else { $true }
    if (-not $onWindows) {
        Fail 'this script targets Windows; use ./bootstrap.sh on macOS and Linux'
        return
    }

    if (-not (Have 'winget')) {
        Fail "winget missing. Install 'App Installer' from the Microsoft Store, then re-run."
        return
    }
    $version = (& winget --version 2>&1 | Select-Object -First 1)
    Ok "winget $version"

    if (Test-Path -LiteralPath $WingetList) {
        $count = @(Get-WingetIdList -Path $WingetList).Count
        Ok "packages/winget.txt ($count ids)"
    }
    else {
        Warn 'packages/winget.txt missing — the winget step will be skipped'
    }

    # Not a gate, just so copy-instead-of-symlink is not a surprise when mise
    # applies [dotfiles] later in this run.
    $unlock = Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' `
        -Name 'AllowDevelopmentWithoutDevLicense' -ErrorAction SilentlyContinue
    if ($unlock -and $unlock.AllowDevelopmentWithoutDevLicense -eq 1) {
        Skip 'Developer Mode on — mise [dotfiles] can make real symlinks'
    }
    else {
        Skip 'Developer Mode off — mise [dotfiles] copies files, junctions dirs'
    }
}

function Step-Winget {
    Say 'winget packages'

    if (-not (Have 'winget')) { Fail 'winget not available'; return }
    if (-not (Test-Path -LiteralPath $WingetList)) {
        Skip 'no packages/winget.txt'
        return
    }

    foreach ($id in Get-WingetIdList -Path $WingetList) {
        if (Test-WingetInstalled -Id $id) {
            Skip $id
            continue
        }
        # One bad package must not take the rest of the run with it.
        if (Install-WingetPackage -Id $id) { Ok $id }
        else { Fail "$id (winget install failed)" }
    }
}

function Step-Mise {
    Say 'mise'

    $script:Mise = Resolve-Mise
    if ($script:Mise) {
        $version = (& $script:Mise --version 2>&1 | Select-Object -First 1)
        Skip "mise present ($version)"
        return
    }

    if (-not (Have 'winget')) { Fail 'winget not available, cannot install mise'; return }
    if (-not (Install-WingetPackage -Id 'jdx.mise')) {
        Fail 'mise install failed'
        return
    }

    Update-PathFromEnvironment
    $script:Mise = Resolve-Mise
    if (-not $script:Mise) {
        Fail 'mise installed but not on PATH — open a new PowerShell window and re-run'
        return
    }
    Ok "mise installed ($(& $script:Mise --version 2>&1 | Select-Object -First 1))"
}

function Step-Bootstrap {
    Say 'mise bootstrap'

    if (-not $script:Mise) { $script:Mise = Resolve-Mise }
    if (-not $script:Mise) { Fail 'mise not installed — run the mise step first'; return }
    if (-not (Test-Path -LiteralPath $ConfigFile)) { Fail "no $ConfigFile"; return }

    # From the repo root, so mise discovers this repo's mise.toml (and the
    # platform overlay mise.windows.toml that .miserc.toml's auto_env pulls in).
    Push-Location -LiteralPath $Dotfiles
    try {
        if (Test-MiseTrusted -Path $Dotfiles) {
            Skip 'config already trusted'
        }
        else {
            $code = Invoke-Native -Exe $script:Mise -Arguments @('trust', $ConfigFile)
            if ($code -eq 0) { Ok 'config trusted' }
            else { Fail "mise trust exited $code"; return }
        }

        # Converges: dotfiles, repos, tools and the `bootstrap` task all skip
        # whatever is already in its desired state.
        $code = Invoke-Native -Exe $script:Mise -Arguments @('bootstrap', '--yes')
        if ($code -eq 0) { Ok 'mise bootstrap complete' }
        else { Fail "mise bootstrap exited $code" }
    }
    finally {
        Pop-Location
    }
}

# -------------------------------------------------------------------- main --
$Order = [ordered]@{
    preflight = ${function:Step-Preflight}
    winget    = ${function:Step-Winget}
    mise      = ${function:Step-Mise}
    bootstrap = ${function:Step-Bootstrap}
}

if ($List) {
    $Order.Keys | ForEach-Object { Write-Host $_ }
    exit 0
}

$toRun = @()
if ($Steps) {
    foreach ($name in $Steps) {
        if ($Order.Contains($name)) { $toRun += $name }
        else {
            Write-Host "unknown step: $name" -ForegroundColor Red
            Write-Host "steps: $($Order.Keys -join ' ')"
            exit 2
        }
    }
}
else {
    $toRun = @($Order.Keys)
}

foreach ($name in $toRun) {
    & $Order[$name]
    Write-Host ''
}

if ($script:Failures.Count -gt 0) {
    Write-Host "Finished with $($script:Failures.Count) problem(s):" -ForegroundColor Yellow
    foreach ($failure in $script:Failures) { Write-Host "  x $failure" -ForegroundColor Red }
    Write-Host 'Re-run this script after fixing them; completed steps are skipped.'
    exit 1
}

Write-Host 'Done.' -ForegroundColor Green
Write-Host 'Open a new PowerShell window to pick up the environment, then see docs/windows.md'
Write-Host 'for the manual steps (Windows Update, WSL, PowerToys remaps, power plan).'
