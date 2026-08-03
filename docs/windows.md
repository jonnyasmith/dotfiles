# Windows (native)

Harvested from the deleted `main` branch, tag `archive/main`: `windows/README.md`,
`windows/setup.txt`, `windows/install.ps1`, `windows/install/{winget,choco,link,fonts,setup}.ps1`
and `windows/post-install.ps1`.

Everything in this file needs a human: a reboot, a GUI sign-in, an elevated
prompt, or a control panel. Packages, dev tools and dotfiles are **not** here —
`bootstrap.ps1` and `mise bootstrap` own those. The winget IDs live in
`packages/winget.txt`; the tools and dotfiles live in `mise.toml` and
`mise.windows.toml`.

This is the native-Windows runbook. The Linux side of the same machine is
`docs/wsl.md`.

---

## 1. Windows Update

Settings > Windows Update > **Check for updates**, and keep going until it
reports nothing outstanding. Reboot when asked. Doing this first means WSL,
winget and the Store are all at a version the rest of this file assumes.

## 2. Prerequisites for the bootstrap

`bootstrap.ps1` needs two things that cannot bootstrap themselves:

- **winget** — ships with Windows 11. If `winget --version` is not found,
  install **App Installer** from the Microsoft Store.
- **git** — needed to clone this repo before the script can install anything:

  ```powershell
  winget install --id Git.Git --exact
  ```

  (`Git.Git` is also in `packages/winget.txt`, so a later run reports it as
  already installed.)

## 3. Clone and bootstrap

Run **without** elevation. The old runbook was explicit about this and it still
holds: everything here is per-user, and an elevated shell would install the
winget packages for the wrong profile.

```powershell
git clone git@github.com:jonnyasmith/dotfiles.git "$env:USERPROFILE\.dotfiles"
cd "$env:USERPROFILE\.dotfiles"
.\bootstrap.ps1
```

The SSH clone needs 1Password's agent (section 4); clone over HTTPS and change
the remote later if you are setting the agent up afterwards.

If PowerShell refuses to run the script, the execution policy is stricter than
the default `RemoteSigned`:

```powershell
pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

`bootstrap.ps1` installs the winget list, installs mise if missing, then runs
`mise trust` and `mise bootstrap --yes`. It is idempotent: `+` means it did
something, `.` means it was already done. `.\bootstrap.ps1 -List` prints the
step names, and a step name as an argument runs just that step.

**Symlinks.** The script creates none; mise's `[dotfiles]` does. Without
elevation Windows will not create file symlinks, so mise copies the file and
uses a junction for a directory. That is fine — but it means editing
`~\.gitconfig` in place does not write back to the repo. Turning on Settings >
System > For developers > **Developer Mode** lets an unelevated process create
real symlinks; do that if you want to edit dotfiles through their applied path.

## 4. 1Password and the SSH agent

Sign in to the 1Password desktop app, then Settings > Developer > **Use the SSH
agent**. Windows' own OpenSSH client talks to it over the
`\\.\pipe\openssh-ssh-agent` named pipe, so nothing else is needed for
`git@github.com` remotes — *provided* git uses that ssh and not the one Git for
Windows bundles, which cannot reach the pipe. The repo's git config pins it:

```ini
[core]
    sshCommand = C:/Windows/System32/OpenSSH/ssh.exe
```

That line is Windows-only and comes from the archived
`windows/git/gitconfig.symlink`; it belongs in the `os() == "windows"` branch of
`home/.config/git/config.os.tmpl`, together with `autocrlf = input`. Verify with
`ssh -T git@github.com`.

## 5. PowerShell modules

The profile is `home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`,
applied by mise `[dotfiles]` to `~\Documents\PowerShell\` — i.e. **pwsh 7+**
(`Microsoft.PowerShell` from `packages/winget.txt`). Windows PowerShell 5.1
reads `~\Documents\WindowsPowerShell\` instead and is deliberately unmanaged.

It imports these only if they are present, so the shell works without them.
They come from the PowerShell Gallery, not from this repo — install once per
machine:

```powershell
Install-Module -Name PSFzf -RequiredVersion 2.5.16 -Force
Install-Module -Name Terminal-Icons -Repository PSGallery -Force
Install-Module z -AllowClobber -Force
```

Exactly as in the archived `windows/post-install.ps1`. Add `-Scope CurrentUser`
to each if you would rather not get an elevation prompt for `Program Files`.
`PSFzf` also needs the `fzf` binary, which mise installs.

**Aliases deliberately not ported** from `home/.config/zsh/aliases.zsh`:
`auu` / `nuu` (apt and nala — those belong in WSL, see `docs/wsl.md`), `buu`
(Homebrew), `code` (aliased to `code-insiders` on macOS; Windows installs
stable), `wtc` / `wtr` / `wtl` (the `worktree` helper they call is not in this
repo), and `flush`, `sniff`, `httpdump`, `cleanup`, `fs`, `emptytrash`,
`hidedesktop`, `showdesktop`, the `GET`/`HEAD`/`POST` `lwp-request` loop and
the `grep`/`df`/`du` coreutils wrappers — macOS- or GNU-only, with no Windows
equivalent worth faking.

## 6. Nerd font

Windows Terminal's settings ask for **FiraMono Nerd Font Mono**
(`profiles.defaults.font.face`), and nothing installs it: `setup.txt` says "add
fonts to repo and remove chocolatey", and the fonts never made it into the repo.
Until they do, install by hand — download `FiraMono.zip` from
<https://github.com/ryanoasis/nerd-fonts/releases>, select the `.ttf` files,
right-click > **Install for all users**. Any other Nerd Font works too; change
the face name in the Terminal settings to match.

## 7. PowerToys keyboard remaps

`setup.txt`: "setup power toys for keyboard remaps". PowerToys (installed from
`packages/winget.txt`) > **Keyboard Manager** > Remap a key. This is the
day-to-day path and it replaces SharpKeys for anything that only has to work
inside a desktop session.

SharpKeys is still in the package list because it does something Keyboard
Manager cannot: it writes the `HKLM\SYSTEM\CurrentControlSet\Control\Keyboard
Layout` scancode map, which applies before login and with no process running.
Use it for a remap you want at the logon screen (it needs a reboot to take
effect); use PowerToys for everything else.

## 8. Power plan and lid close

`setup.txt`: "edit power plan / shut laptop lid options". Win+R >
**`powercfg.cpl`**:

- *Change plan settings* on the active plan — set the display and sleep timeouts
  for battery and mains.
- *Choose what closing the lid does* — set the lid action for battery and mains.

There is no per-user setting for these; they are machine-wide and the dialog
elevates itself.

## 9. WSL

`setup.txt`: "move wsl to separate step". It is a separate step, and a separate
document. From an **elevated** PowerShell:

```powershell
wsl --install --distribution Debian
```

This enables the Virtual Machine Platform and WSL features and needs a reboot on
a machine that has never had WSL. Everything after that — creating the UNIX
user, the Linux dotfiles, reaching the Windows 1Password agent from inside WSL —
is in **`docs/wsl.md`**.

The archived Windows Terminal settings already carry a `Debian` profile
(`source: Windows.Terminal.Wsl`), so the distribution shows up in the tab
dropdown once it is installed.

## 10. Dropped from the archived runbook

Recorded here so nobody re-adds them:

| Dropped | Why |
| --- | --- |
| `git clone .../packer.nvim` into `nvim-data\site\pack\packer\start`, and `:PackerInstall` | `home/.config/nvim` is an AstroNvim/lazy.nvim config; packer is not used and is archived upstream |
| `Copy-Item ...\windows\files\fzf.exe C:\Windows\System32` | mise `[tools]` installs fzf on PATH; nothing needs a binary in a system directory |
| Chocolatey install (`community.chocolatey.org/install.ps1`) and `choco install nerd-fonts-FiraMono` | `setup.txt`: "add fonts to repo and remove chocolatey" — section 6 |
| `windows/install/fonts.ps1` | it installed from a `fonts\` directory the repo never had |
| `windows/install/link.ps1` (`New-Item -ItemType SymbolicLink` × 4) | mise `[dotfiles]` links dotfiles on every OS |
| `nvm install lts` / `nvm use lts`, `CoreyButler.NVMforWindows` | mise `[tools]` owns node |
| `npm i prettier -g` | a per-project dev dependency, not a machine-global tool |
| `Microsoft.DotNet.SDK.6`, `.7`, `.8` | mise `[tools]` installs the SDKs side by side (`dotnet = ["10", "8"]`) |
| `Neovim.Neovim`, `Starship.Starship`, `junegunn.fzf`, `zig.zig` | all in mise's registry — `mise.windows.toml` `[tools]` |
| `Docker.DockerDesktop` | `setup.txt`: "remove docker desktop"; `RedHat.Podman-Desktop` stays |
| `iex (... amnweb/nf-installer ...)` | a `curl \| iex` installer for a font; section 6 does it from the upstream release |
| `windows/git/gitconfig.symlink`, `windows/vim/ideavimrc.symlink` | superseded by the shared `home/.config/git/config` and `home/.ideavimrc` (the ideavimrc was byte-identical); the two genuinely Windows-only git settings are in section 4 |
