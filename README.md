# dotfiles

One branch, every machine: macOS, Fedora, Debian/Ubuntu, Arch, Raspberry Pi,
WSL, and native Windows.

There used to be a branch per OS, and each carried a README you stepped through
by hand. They drifted, because a fix made on the mac never made it to the other
five. That is gone. The machine is now **declared** in `mise.toml`, and
`mise bootstrap` converges it.

## Set up a machine

```bash
git clone https://github.com/jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./bootstrap.sh
exec zsh
```

On Windows, `.\bootstrap.ps1` instead.

Clone over **HTTPS**: SSH to GitHub cannot work until the dotfiles are applied,
because the `IdentityAgent` line pointing ssh at 1Password's socket is *in this
repo*. Swap the remote afterwards:

```bash
git remote set-url origin git@github.com:jonnyasmith/dotfiles.git
```

The repo **must** live at `~/.dotfiles`. `mise.toml`'s `dotfiles.root` is a
literal path — mise does not template `[settings]` — so `bootstrap.sh` refuses
to run anywhere else rather than silently linking everything into a directory
that does not exist.

`bootstrap.sh` is idempotent. Re-run it any time; converged steps report and
change nothing.

```bash
./bootstrap.sh              # converge
./bootstrap.sh --dry-run    # show what would change, touch nothing
./bootstrap.sh --status     # what is currently out of sync
```

### The one prerequisite

**Sign in to 1Password** and enable *Settings → Developer → Use the SSH agent*.
Nothing else needs a human before `bootstrap.sh`. In particular you no longer
install Homebrew first — mise ships its own Homebrew support and does not
require it.

Two things it cannot finish for you, both reported at the end of a run:

- **tmux plugins** — press `prefix + I` inside tmux once.
- **VS Code** — if the `code` CLI is missing, run *Shell Command: Install 'code'
  command in PATH* from the palette, then `mise run setup:vscode`.

Per-OS prerequisites that genuinely need a human — installing the OS, disk
partitioning, GUI sign-ins, anything needing a reboot — are in `docs/`:
[arch](docs/arch.md) · [fedora](docs/fedora.md) · [ubuntu](docs/ubuntu.md) ·
[raspberry-pi](docs/raspberry-pi.md) · [wsl](docs/wsl.md) ·
[windows](docs/windows.md).

## How one config covers every OS

```
mise.toml           everything shared, and every OS's package list
mise.macos.toml     ─┐
mise.linux.toml      ├─ loaded only on that platform
mise.windows.toml   ─┘
.miserc.toml        auto_env = true, which is what makes the above load
home/               mirrors $HOME — every dotfile source
docs/               the parts of each runbook a human must still do
packages/           winget ids and VS Code extension ids
bootstrap.sh        installs mise, then `mise bootstrap`
bootstrap.ps1       the same, for native Windows
```

Three mechanisms do all the work:

**1. Package entries are keyed by manager, and mise skips managers the machine
does not have.** So Debian, Fedora, Arch and macOS package lists all live
together in `mise.toml`, and each machine takes only its own. Skipped entries
are *reported*, not silently dropped — a run on this mac ends with:

```
bootstrap: follow-up
  - apt: 19 package(s) skipped (only available on linux)
  - dnf: 10 package(s) skipped (only available on linux)
  - pacman: 28 package(s) skipped (only available on linux)
```

**2. Anything in mise's registry is a `[tools]` entry, declared once.** node,
neovim, starship, fzf, ripgrep, lazygit, zoxide, gh, jq, terraform, uv, zig used
to be installed six different ways across the branches — `nvm | bash`,
`dotnet-install.sh`, `snap`, a tarball unpacked into `/opt`, `yay`, `winget`.
Now they are one line each and every machine gets the same version. This is what
shrank the per-distro package lists to the genuine rump: system libraries, GUI
apps, fonts, and 1Password.

**3. Config that really does differ per OS is a template.** Five files render
`{{ os() }}` at apply time; everything else is a plain symlink. The whole
divergence is the 1Password agent socket, git's mergetool paths, ghostty's
mac-only key, `PNPM_HOME`, and a handful of BSD-vs-GNU aliases.

What each `[bootstrap.*]` section replaced:

| was | now |
|---|---|
| `Brewfile`, and five per-distro package arrays | `[bootstrap.packages]` |
| four `git clone` lines in every README, plus tpm | `[bootstrap.repos]` |
| GNU stow, and three symlink scripts hardcoded to `/home/jonny` | `[dotfiles]` |
| `bootstrap.sh`'s `defaults` step | `[bootstrap.macos.*]` |
| "install zsh, then remember to `chsh`" | `[bootstrap.user].login_shell` |
| `Brewfile.vscode` + a bespoke install step | `[tasks."setup:vscode"]` |
| the imperative rump of each README | `[tasks."setup:*"]` |

### Adding things

```bash
mise bootstrap packages use brew:ffmpeg apt:libssl-dev   # a system package
mise use -g ripgrep@latest                               # a dev tool
mise bootstrap dotfiles add ~/.config/foo/bar            # a new dotfile
code --list-extensions | sort > packages/vscode.txt      # re-record extensions
```

Commit the result. There is no separate manifest to keep in sync.

## Dotfiles

`home/` mirrors `$HOME`, and `[dotfiles]` in `mise.toml` says how each path is
applied. The mode matters, and is chosen by **who writes the file**:

| mode | for | examples |
|---|---|---|
| `symlink` | we own it outright; editing `~` edits the repo | `.zshrc`, `.gitconfig`, `starship.toml` |
| `symlink-each` | we own the files, a tool writes *siblings* into the same dir | `nvim/` (spell, netrwhist), `tmux/` (tpm plugins), `herdr/` |
| `copy` | the tool rewrites the file *itself*, in place | `btop.conf`, `htoprc`, `karabiner.json`, `gh/config.yml` |
| `template` | genuinely differs per OS | `ssh/config`, `git/config.os`, `zsh/os.zsh` |

`symlink-each` is why the repo no longer collects machine state. Previously
`~/.config/nvim` was one symlink to a repo directory, so everything nvim wrote
landed *in the repo* and had to be gitignored. Now the directory is real and
only the files we own are linked.

For a `copy` or `template` target, editing `~` does **not** edit the repo — that
is the point, since something else owns the file. Pull deliberate changes back
with `mise bootstrap dotfiles add <path>`.

**Keep configs free of absolute paths.** `$HOME`, not `/Users/jonny`.

## Shell files and tool precedence

Unchanged by the migration, and still the subtlest thing here. The three zsh
files decide which `python3` and `node` you get, and run in a fixed order:

| file | sourced by | does |
|---|---|---|
| `.zshenv` | **every** zsh, incl. `zsh -c` | PATH and env only: uv's `~/.local/bin`, `cargo/env`, `BUN_INSTALL`, mise shims |
| `.zprofile` | login zsh | `brew shellenv` (Apple Silicon, Intel, then Linuxbrew), OrbStack, then re-asserts the shims |
| `.zshrc` | interactive zsh | oh-my-zsh, `~/.config/zsh/*.zsh`, starship, `mise activate`, then demotes the shims |

`mise activate` runs in `.zshrc`, so **only interactive shells** get it. Git
hooks (husky runs `npx lint-staged` under `sh`), editor- and GUI-spawned shells,
LaunchAgents and cron get none of it — and without the shims they see no
`node`/`npx`/`pnpm` at all, plus the wrong `python3`, because both `/usr/bin`
(Xcode's 3.9) and `/opt/homebrew/bin` (python@3.14, a dependency of azure-cli /
pipx / platformio) ship one.

So the shims go at the **front** of PATH, not the back. `.zshenv` defines
`mise-shims-first` and `mise-shims-last` as functions because the ordering has
to be re-asserted twice more:

- **`.zprofile`** calls `mise-shims-first` again — `brew shellenv` prepends
  `/opt/homebrew/bin` *after* `.zshenv` has run.
- **`.zshrc`** calls `mise-shims-last` after `mise activate`, which supersedes
  the shims with the real install dirs and adds a uv project's `.venv/bin`
  (`python.uv_venv_auto`). A shim left in front would shadow that project
  interpreter with the global one.

Verified after the migration:

```
zsh -c   python3 → shims/python3       node → shims/node    bun → shims/bun
zsh -lc  python3 → shims/python3       (git/curl still brew's)
zsh -ic  python3 → installs/python/3.13/bin/python3
                   inside a uv project → .venv/bin/python
```

`~/.config/zsh/os.zsh` is rendered per-OS and picked up by the
`for config (~/.config/zsh/*.zsh)` loop, which runs *before* `mise activate`.
It carries `SSH_AUTH_SOCK`, `PNPM_HOME`, and the BSD-vs-GNU aliases.

Git config is XDG (`~/.config/git/config`), not `~/.gitconfig`. Git reads both,
with `~/.gitconfig` last and therefore winning, so keep only one — a stray
`~/.gitconfig` will silently override this. The per-OS mergetool paths come from
`config.os`, pulled in by an `[include]`; git ignores a missing include, so this
is safe before the template has rendered.

`~/.config/gh/hosts.yml` holds an OAuth token, is gitignored, and is
deliberately unmanaged — run `gh auth login` on a new machine.

## SSH keys and identities

Three keys live in 1Password, and both the key *and* the commit email are
picked from the remote URL. Nothing is switched by hand.

| remote | key (1Password item) | commit email |
|---|---|---|
| everything not listed below | `SSH Key - Ed25519` | personal |
| the work GitHub org | `SSH Key - Ed25519 Work` | work |
| `ssh.dev.azure.com` | `SSH Key - Work` (RSA) | work |

Azure DevOps accepts **only** the RSA key; both Ed25519 keys are rejected there.

**This repo is public, so the work org name and work email are not in it.**
They live in two untracked files that git picks up from `~/.config/git/`:

| file | holds |
|---|---|
| `config.local` | the org name, its `github-work` URL rewrite, and the two `includeIf` conditions that key off it |
| `config.work` | `[user] email` for work repos |

Set them up once per machine:

```bash
cp home/.config/git/config.local.example ~/.config/git/config.local
$EDITOR ~/.config/git/config.local            # replace ORG
printf '[user]\n\temail = you@example.com\n' > ~/.config/git/config.work
```

A missing include is *silently ignored* by git, so skipping this does not
error — work repos just quietly commit under the personal identity, which is
the exact failure the routing exists to prevent. `bootstrap.sh` therefore
warns on every run until `config.local` exists.

This works because a relative `include.path` resolves against the directory of
the config file **as git opened it** — `~/.config/git/`, not the symlink's
target inside `~/.dotfiles`. So the untracked files sit next to the symlink and
cannot be committed by accident.

- **`~/.ssh/config`** (rendered from `home/.ssh/config.tmpl`) pins one key per
  host with `IdentitiesOnly yes`. Without it ssh offers every key in the agent
  and the first one the server accepts wins — which silently authenticated work
  repos as the personal account. The `github-work` alias is just a label and
  stays tracked. Each block is `Match originalhost`, **not** `Host`: the alias
  sets `HostName github.com`, and a `Host github.com` block matches it too, so
  both identities load and agent order picks the account — the same bug
  `IdentitiesOnly` was meant to close.
- **`home/.ssh/1password/*.pub`** are public-key stubs, committed deliberately.
  `IdentityFile` needs a local file to name *which* agent key to use; the
  private half never leaves 1Password. ssh matches on the key blob, not the
  comment, so the comments are generic. Regenerate with
  `~/.ssh/1password/refresh`, which maps 1Password item titles to filenames —
  rename an item in the vault and you must update its `map()`.

Two traps worth remembering:

- `hasconfig` matches the remote URL **as stored**, not as rewritten, so the
  patterns use `git@github.com:...`. Both the `git@` and `ssh://` spellings
  need their own block.
- `**` is only wildcard-magic directly after a `/`. `...azure.com:**` matches
  nothing and fails **silently**; `...azure.com:v3/**` is correct.

The agent socket differs per OS — a Group Container path on macOS,
`~/.1password/agent.sock` on Linux, and on WSL that same path fed by an
npiperelay bridge to the Windows agent ([docs/wsl.md](docs/wsl.md)).

```bash
ssh -T git@github.com          # personal account
ssh -T git@github-work         # work account
git -C <repo> config user.email
```

## Dev tools (mise)

`[tools]` in `mise.toml` owns the runtimes and every registry-backed CLI.
`.zshrc` runs `mise activate zsh`, so PATH is rewritten on `cd`.

```bash
mise install     # install everything declared
mise ls          # what is installed
mise outdated    # what is behind
mise upgrade     # bump tools pinned to a moving target
```

Do **not** install node, nvm, pnpm, bun or the .NET SDKs from a distro package
manager or a vendor's `curl | bash` — mise owns those, and a second copy will
shadow it or self-update behind its back. mise sets `DOTNET_ROOT` and
`DOTNET_MULTILEVEL_LOOKUP` itself; never export them.

Per-project versions come from files already in your repos — `global.json`,
`.nvmrc` / `.node-version`, `.python-version` — because
`idiomatic_version_file_enable_tools` is set.

### Python

Homebrew's `python@3.14` is a **dependency** of `azure-cli`, `pipx`, `pytest`
and `platformio`, so it is upgraded whenever any of those are, and every venv
built against it drifts. Leave it installed — those formulae each have a private
`libexec` venv, so none of them consume `/opt/homebrew/bin/python3`. Never remove
`/usr/bin/python3` either; that is Apple's.

| owns | what |
|---|---|
| mise | the interpreter — which `python3` you get, per directory |
| uv | per-project `.venv` and `uv tool install` |
| brew | nothing you invoke; just a dependency of the formulae above |

`python.uv_venv_auto` is on, so a project's `.venv` activates on `cd`. Build
venvs from a mise or uv python, never a bare `python3 -m venv` picked up before
`mise activate` runs.

### Bun

mise owns the `bun` binary. `~/.bun` stays, because it is two separate things
and only one of them was the runtime:

| path | what | owner |
|---|---|---|
| `~/.bun/bin/bun` | the runtime — **deleted**, comes from mise | mise |
| `~/.bun/bin/*` | `bun install -g` binaries | bun |
| `~/.bun/install/global/` | the global `node_modules` behind them | bun |
| `~/.bun/_bun` | completions, sourced by `.zshrc` | `bun completions` |

So `BUN_INSTALL` and `$BUN_INSTALL/bin` on PATH are still needed — they point at
bun's *global package* dir, not the runtime. Never run `bun upgrade`; use
`mise upgrade bun`.

## Known rough edges

Things that are deliberate, or upstream, and will look like bugs otherwise:

- **`dotfiles.root` must be absolute or `~/`-prefixed.** A relative value is
  written verbatim into the symlink target, producing dangling links that
  `mise bootstrap dotfiles status` still reports as `applied`. `[settings]` is
  not templated, so `{{config_root}}` does not work there either.
- **`auto_env` must live in `.miserc.toml`.** Config discovery happens before
  `mise.toml` is read, so setting it there has no effect and the
  `mise.<os>.toml` files silently never load. Defaults to on in mise 2027.6.0.
- **`[dotfiles]` has no `os` field.** An `os` key is ignored without warning.
  Platform-only targets must go in a `mise.<os>.toml`.
- **`[bootstrap.user].login_shell` is not templated** and must be a literal
  absolute path — hence one per platform file.
- **Same-named tasks across merged config files replace each other silently.**
  There is exactly one `[tasks.bootstrap]`, in `mise.toml`; platform files
  define `setup:<platform>` and are reached by its `depends = ["setup:*"]`
  glob. A *literal* missing dependency is a hard error, so the glob is
  load-bearing, not stylistic.
- **`[bootstrap.hooks.*].run` is not templated; `[tasks.*].run` is.** Keep `{{`
  and `{%` out of task bodies.
- **No `winget` manager**, so Windows packages come from `packages/winget.txt`
  via `bootstrap.ps1`.
- **The `vscode:` package plugin in mise's docs does not exist** — that URL
  404s, and declaring it fails the whole bootstrap at the first phase. Hence
  `[tasks."setup:vscode"]`.
- **Two casks are not declared**: `microsoft-teams` and `microsoft-auto-update`
  are pkg-installer casks, which mise's built-in cask support cannot drive
  (`pkg installer choices are not supported yet`, and a `sudo` prompt with no
  TTY). Teams is installed by `[tasks."setup:macos"]` through real Homebrew when
  present.
- **`btop` is `os = ["linux"]`** — its aqua backend has no darwin build. macOS
  takes it from brew.
- **The dotfiles phase is all-or-nothing on pre-existing files.** If any target
  mise would symlink already exists as a real file, it lists every conflict and
  applies *nothing* — so a first run on a machine that already had AstroNvim,
  herdr or 1Password installed leaves every other dotfile unapplied too. Back
  the conflicts up and re-run `mise bootstrap dotfiles apply --force`; `copy`
  and `template` targets are overwritten either way and never appear in that
  list. Missing parent directories are *not* a problem — mise creates them.
- **A dangling symlink in a target's path fails the phase with a bare
  `ln -sf ... No such file or directory`.** Left over from the pre-mise stow
  layout, which linked `~/.config/zsh -> ~/.dotfiles/.config/zsh` (the repo now
  keeps everything under `home/`). `find ~ -maxdepth 4 -xtype l` finds them.
- **`gsettings` is not a GNOME probe.** It ships with glib2, so the old
  `command -v gsettings` guard also fired on COSMIC, KDE and anything else with
  GTK installed, writing ~20 GNOME Shell keys into dconf that nothing reads. The
  cross-desktop GTK keys are now `[tasks.gtk-settings]`; the Shell/mutter ones
  are `[tasks.gnome-settings]`, gated on `XDG_CURRENT_DESKTOP` matching `*GNOME*`
  — which also skips a bootstrap run over SSH, where that variable is unset.
- **Package lists have no desktop dimension**, only `os`. `gnome-tweaks` is
  therefore installed from inside `[tasks.gnome-settings]` rather than declared,
  so a COSMIC or headless box does not get a GNOME-only GUI.

## History

The old per-OS branches are deleted but preserved as tags, so nothing is lost:

```bash
git tag -l 'archive/*'
git show archive/debian:debian.md
```

`archive/arch`, `archive/arch-linux`, `archive/deb`, `archive/debian`,
`archive/wsl`, `archive/main`, `archive/master`. Their runbooks were harvested
into `docs/` and the `mise.*.toml` files; their configs were all strictly older
than the mac branch's.
