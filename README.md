# dotfiles

One branch, every machine: macOS, Debian, Fedora, Arch, Raspberry Pi, WSL, and
native Windows.

There used to be a branch per OS, and each carried a README you stepped through
by hand. They drifted, because a fix made on the mac never made it to the other
five. That is gone. The machine is now **declared** in `mise.toml`, and
`mise bootstrap` converges it.

## Set up a machine

Follow the runbook for the machine you are building. Each is the whole
sequence — install media to first login — and nothing in it is optional:

| Machine | Runbook |
| --- | --- |
| Debian laptop or desktop | [docs/debian.md](docs/debian.md) |
| Fedora | [docs/fedora.md](docs/fedora.md) |
| Arch | [docs/arch.md](docs/arch.md) |
| Raspberry Pi | [docs/raspberry-pi.md](docs/raspberry-pi.md) |
| Debian under WSL | [docs/wsl.md](docs/wsl.md) |
| Native Windows | [docs/windows.md](docs/windows.md) |
| macOS | the three lines below; there is nothing else |

All of them end in the same three lines:

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
- **Docker on Linux** — group membership only takes effect after a re-login,
  and under WSL the `/etc/wsl.conf` boot stanza is reported, not written.

VS Code extensions are not a step at all: Settings Sync owns them
(`docs/adr/0002-vscode-extensions-are-sync-owned.md`).

What the runbooks add on top is only what a human must do: install media, disk
partitioning, GUI sign-ins, and the steps that need a reboot.

## How one config covers every OS

```
mise.toml           everything shared, and every OS's package list
mise.macos.toml     ─┐
mise.linux.toml      ├─ loaded only on that platform
mise.windows.toml   ─┘
.miserc.toml        auto_env = true, which is what makes the above load
home/               mirrors $HOME — every dotfile source
desktop/            per-desktop settings: gnome.dconf, gtk.dconf, cosmic/
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

**3. Config that really does differ per OS is a template, environment is not.**
Four files render `{{ os() }}` at apply time; everything else is a plain
symlink. The whole template divergence is the 1Password agent socket, git's
mergetool paths, and a handful of BSD-vs-GNU aliases.
Per-OS *environment* — `SSH_AUTH_SOCK`, `PNPM_HOME` — is `[env]` in
`mise.linux.toml` / `mise.macos.toml` instead, so it reaches `mise x`, `mise
en`, tasks and shims rather than interactive zsh alone.

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
# VS Code extensions are not here — Settings Sync owns them (docs/adr/0002).
```

Commit the result. There is no separate manifest to keep in sync.

## Distribution and desktop are two axes

Distribution and desktop vary independently — GNOME on Debian and Arch, GNOME
*or* COSMIC on Fedora, and on this laptop both installed side by side. So they
are two independent sets of sibling `setup:*` tasks, never nested:

| axis | task | guard |
|---|---|---|
| distribution | `setup:fedora` | `dnf` on PATH |
| | `setup:debian` | `apt-get` on PATH |
| | `setup:arch` | `pacman` on PATH |
| desktop | `setup:gtk` | `dconf` on PATH |
| | `setup:gnome` | `gnome-shell` **installed** |
| | `setup:cosmic` | `cosmic-comp` **installed** |

Both desktop tasks can fire on one machine, and should: each desktop is
configured whether or not you are currently logged into it, so switching
sessions needs no re-bootstrap.

**Detection is on what is installed, never on what is running.**
`$XDG_CURRENT_DESKTOP` describes only the live session — it is unset over SSH
and on a tty, and on a dual-desktop machine it would silently leave the other
desktop unconfigured. `gsettings` is not a GNOME probe either: it ships with
glib2 and exists on anything with GTK.

The payloads are data, not shell:

| desktop | store | applied by |
|---|---|---|
| GTK apps, any desktop | dconf | `dconf load / < desktop/gtk.dconf` |
| GNOME | dconf | `dconf load / < desktop/gnome.dconf` |
| COSMIC | RON files in `~/.config/cosmic/<component>/v1/<key>` | copied from `desktop/cosmic/` |

`dconf load` merges, is idempotent, and needs no installed schema — so a
`gnome.dconf` key for a component this box lacks is written silently instead of
erroring. The cost is that it does not validate: a section header is a dconf
*path*, not a schema id, and the two differ (`org.gtk.Settings.FileChooser`
lives at `/org/gtk/settings/file-chooser`). A wrong path is written and then
read by nobody, so **`mise run check:dconf`** validates both payloads against
the installed schema XML. Run it after editing them.

COSMIC is copied rather than symlinked because `cosmic-config` owns those files
at runtime and rewrites them on every GUI change; the repo is the seed for a new
machine, and a setting changed in Settings is copied back by hand. `@HOME@` in
`desktop/cosmic/` is expanded at apply time, which is what keeps the `Spawn()`
paths in the shortcut bindings machine-independent.

## Dotfiles

`home/` mirrors `$HOME`, and `[dotfiles]` in `mise.toml` says how each path is
applied. The mode is chosen by two independent properties: is every file in the
target one whose *content* this repo owns, and does another process create
*new* files in the same directory.

| mode | for | examples |
|---|---|---|
| `symlink` | every file ours, nothing foreign writes there | `.zshrc`, `.gitconfig`, `starship.toml`, `nvim/`, `tmux/` |
| `symlink-each` | every file ours, a foreign writer that cannot be relocated | none — see below |
| `copy` | the tool rewrites the file *itself*, in place | `btop.conf`, `htoprc`, `karabiner.json`, `gh/config.yml` |
| `template` | genuinely differs per OS | `ssh/config`, `git/config.os`, `zsh/os.zsh` |

Whole-directory `symlink` is the default, and a foreign writer that
configuration can point elsewhere is **relocated** rather than worked around:
tpm now writes to `~/.local/share/tmux/plugins`, which is what lets
`~/.config/tmux` be a single link. herdr cannot be relocated, so its entry
names the one file we own instead of the directory.

That leaves `symlink-each` with no qualifying target. It stays documented so it
is not reintroduced as a default; a surviving entry is a mistake. See
`docs/adr/0001-dotfiles-link-whole-directories.md`.

The cost is that nvim's `spell/` and `.netrwhist` land inside the working tree.
They are gitignored, and those two entries are now load-bearing rather than
defensive. The gain is that a file added to the repo exists in `$HOME`
immediately, and a file created in `$HOME` lands in the repo — neither was true
with per-file links.

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
It carries the BSD-vs-GNU aliases and nothing else: `[shell_alias]` is the one
mise mechanism that cannot replace it, being unsupported in nushell and
PowerShell, and half of these are probed at runtime because Tera knows the OS
but not the distro. The environment that used to live here is now `[env]` in
the per-OS configs.

Git config is XDG (`~/.config/git/config`), not `~/.gitconfig`. Git reads both,
with `~/.gitconfig` last and therefore winning, so keep only one — a stray
`~/.gitconfig` will silently override this. The per-OS mergetool paths come from
`config.os`, pulled in by an `[include]`; git ignores a missing include, so this
is safe before the template has rendered.

`push.default = current` pushes a branch to the same name on the remote but
records **no** upstream, so every locally-created branch stayed untracked and
`git pull` failed with *"There is no tracking information for the current
branch"* until someone ran `git push -u` by hand. `push.autoSetupRemote = true`
sets the upstream on the first push instead. Branches pushed before that was
added still need one `git branch --set-upstream-to=origin/<name>`.

`~/.config/gh/hosts.yml` holds an OAuth token, is gitignored, and is
deliberately unmanaged — run `gh auth login` on a new machine.

## tmux dev layout

`prefix + D` builds the standard layout in the current window:

```
┌──────────────────────────────┐
│              ai              │  top pane
├────────┬─────────┬───────────┤
│  nvim  │ lazygit │ terminal  │  bottom row, exact thirds
└────────┴─────────┴───────────┘
```

`BOTTOM_PCT` in `home/.config/tmux/scripts/dev-layout.sh` is the share of the
window height the bottom row takes; the ai pane gets the rest.

Panes are addressed by a **`@role` pane option, not by index**, so the bindings
survive splits and renumbering. `dev-layout.sh` writes `@role`; `jump-pane.sh`
reads it, `unwrap-layout.sh` keeps the pane tagged `ai` and kills the others,
and `tmux.conf` binds:

| binding | does |
|---|---|
| `prefix + D` | build the layout (`dev-layout.sh`) |
| `prefix + =` | re-balance the bottom row (`even-bottom.sh`) |
| `prefix + o` | collapse to the ai pane (`unwrap-layout.sh`) |
| `prefix + a` `e` `g` `t` | jump to `ai` / `editor` / `git` / `terminal` |

The pane border shows `@role` (`pane-border-format`). A window not built by
`dev-layout.sh` has no tagged panes, and `jump-pane.sh` reports that on the
status line rather than erroring.

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
  `IdentitiesOnly` was meant to close. Above six keys in the agent it stops
  being a correctness problem and becomes a hard failure — ssh exhausts the
  server's `MaxAuthTries` and gives up with `Too many authentication failures`.
- **`home/.ssh/1password/*.pub`** are public-key stubs, committed deliberately.
  `IdentityFile` needs a local file to name *which* agent key to use; the
  private half never leaves 1Password. ssh matches on the key blob, not the
  comment, so the comments are generic. Regenerate with
  `~/.ssh/1password/refresh`, which maps 1Password item titles to filenames —
  rename an item in the vault and you must update its `map()`. It writes into
  the working tree, so regenerating shows up as a git diff to commit.
- **`~/.ssh/config` names those stubs by their in-repo path**
  (`~/.dotfiles/home/.ssh/1password/*.pub`), not via `~/.ssh/1password/`. They
  used to be symlinks planted there by the dotfiles phase, and that is a
  single point of failure for the entire machine: ssh treats a missing
  `IdentityFile` as fatal for the host, so the instant those links were absent
  *every* remote broke with `no such identity: ... No such file or directory`
  followed by `Permission denied (publickey)`. They vanished three times in one
  day. Reading the stub out of the working tree means it exists the moment the
  repo is cloned — before mise has run at all — and only git can remove it.

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

`mise upgrade` will not install anything published in the last seven days
(`minimum_release_age` in `[settings]`), so a brand-new release is held back
with a warning naming the date it becomes eligible. That is a supply-chain
quarantine, not a stability preference — most malicious releases are caught
within hours. Two consequences worth knowing:

- `mise upgrade` holds. `mise lock -g --bump` **rolls versions backwards** to
  the newest eligible release. Always `--dry-run` that one.
- A tool that must be current is exempted by name — a per-tool
  `minimum_release_age = "0s"`, or `minimum_release_age_excludes`. Do not lower
  the floor for everything.

Tools that ship their own updater have it switched off — claude, codex,
gemini-cli, copilot and omp — because mise owns the binary and two owners means
silent drift. VS Code is the deliberate exception: it stays vendor-owned, like
its extensions. See `docs/adr/0004-one-updater-per-binary.md`.

Per-project versions come from files already in your repos — `global.json`,
`.nvmrc` / `.node-version`, `.python-version` — because
`idiomatic_version_file_enable_tools` is set.

### GitHub rate limits

Unauthenticated GitHub allows **60 API requests an hour**, per IP. Everyday mise
is nowhere near it — `mise upgrade --dry-run` costs 3 calls, because
`use_versions_host` pulls version lists from `mise-versions.jdx.dev` rather than
the API.

A real `mise lock -g --bump` is the exception. It resolves every platform entry
and needs release-asset metadata for each; `mise.lock` holds 242
`api.github.com/.../releases/assets/N` URLs. That exhausts 60 partway through
and leaves a lockfile built from partial version lists. So pass a token:

```bash
GITHUB_TOKEN="$(gh auth token)" mise lock -g --bump --dry-run   # what would move
GITHUB_TOKEN="$(gh auth token)" mise lock -g --bump             # write it
GITHUB_TOKEN="$(gh auth token)" mise install                    # install the result
```

`gh auth token` reads the token `gh auth login` already put in your keyring.
mise cannot see it on its own — mise reads `GITHUB_TOKEN` or `MISE_GITHUB_TOKEN`
from the environment, and neither is set. **No scopes are needed**; this is
public read metadata. The limit becomes 5,000/hour.

It is deliberately not exported from `.zshenv`: `gh auth token` hits the
keyring, and paying that on every shell start to fix something you meet once a
month is the wrong trade.

### Python

Homebrew's `python@3.14` arrives as a **dependency** of `platformio`, so it is
upgraded whenever that is, and every venv built against it drifts. It used to
be pulled in by `azure-cli`, `pipx` and `pytest` as well; `azure-cli` moved to
`[tools]` and the other two were dropped in favour of uv. Leave it installed —
platformio has a private `libexec` venv, so it does not consume
`/opt/homebrew/bin/python3`. Never remove
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
- **`[bootstrap.hooks.*].run` is not templated; `[tasks.*].run` is.** Keep `{{`,
  `{%` and `{#` out of task bodies. The last one is the one you trip over: a
  bash array length starts `${` + `#`, and Tera then fails the task with
  "Closing comment tag `#}` not found".
- **`--dry-run` invents two warnings and a duplicate hook. A real run has
  neither.** To show what the config would look like *after* linking,
  `mise bootstrap --dry-run` simulates the result: for every `[dotfiles]`
  target under `~/.config/mise`, it reads the repo source and parses it as a
  `mise.toml` under the target's name
  (`config_files_after_dotfiles_dry_run`, `src/cli/bootstrap.rs`). Two of
  those targets are not `mise.toml`-shaped, so the strict field check fires on
  keys that are correct where they live:
  `unknown field in ~/.config/mise/miserc.toml: auto_env` and
  `unknown field in ~/.config/mise/mise.lock: conda-packages` (the latter is
  written by the `conda:clang-format` backend). The same simulation keys
  `mise.macos.toml` and `~/.config/mise/config.macos.toml` separately —
  they are one file, but the symlink does not exist yet to prove it — so
  `[bootstrap.hooks].post-defaults` is collected twice and `killall Finder
  Dock` prints twice. A real run reloads the config instead of simulating it,
  dedupes by resolved path (`mise config ls --json` lists two files, not
  four), and runs the hook once. Verified on mise 2026.7.18; nothing to fix
  here.
- **No `winget` manager**, so Windows packages come from `packages/winget.txt`
  via `bootstrap.ps1`.
- **The `vscode:` package plugin in mise's docs does not exist** — that URL
  404s, and declaring it fails the whole bootstrap at the first phase. It does
  not matter: extensions are sync-owned, so nothing here declares them.
- **pkg-installer casks cannot be declared.** mise's built-in cask support
  rejects them (`pkg installer choices are not supported yet`, and a `sudo`
  prompt with no TTY) and the failure takes the whole packages phase, not just
  the entry. `microsoft-auto-update` was always absent for this reason;
  `microsoft-teams` was the one exception, installed through real Homebrew by
  `setup:macos`. Dropping Teams removed that branch and the last thing on this
  machine that needed real Homebrew.
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
- **Package lists have an `os` dimension but no desktop one.** `gnome-tweaks` is
  therefore installed from inside `[tasks."setup:gnome"]` rather than declared
  in `mise.toml`, so a COSMIC or headless box does not get a GNOME-only GUI.
- **`dconf load` accepts any path**, including one no schema claims. That is
  what makes it usable for a component that may not be installed, and also what
  lets a typo sit there doing nothing — hence `mise run check:dconf`, and the
  `# optional` marker in `desktop/*.dconf` for sections that are legitimately
  absent on some machines.
- **`gi` is not importable from the mise-managed python3**, and PyGObject is a
  separate distro package. `check:dconf` therefore parses
  `/usr/share/glib-2.0/schemas/*.gschema.xml` directly rather than asking
  GSettings.

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
