# Mac Setup

Dotfiles and a bootstrap script for setting up a mac. Configs are symlinked
from this repo with GNU `stow`; packages come from a `Brewfile`; language
runtimes and CLIs come from `mise`.

## Set up a new mac

Three manual prerequisites, because each needs a human:

1. **Update macOS** — `sudo softwareupdate -i -a`
2. **Install Homebrew** — needs sudo and accepts a licence prompt:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. **Sign in to 1Password** and enable *Settings → Developer → Use the SSH
   agent*. Do not test it with `ssh -T git@github.com` yet — that cannot work
   until the `ssh` package is stowed, because the `IdentityAgent` line pointing
   ssh at 1Password's socket lives in `ssh/.ssh/config` *in this repo*.

Clone over **HTTPS**, for the same reason — SSH to GitHub does not work until
`stow` has run:

```bash
git clone https://github.com/jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && git checkout mac
./bootstrap.sh
git remote set-url origin git@github.com:jonnyasmith/dotfiles.git   # now that ssh works
exec zsh
```

Verify SSH once the bootstrap has finished:

```bash
ssh -T git@github.com        # Hi jonnyasmith!
ssh -T git@github-work    # Hi jonnysmith-work!
```

That is the whole setup. `bootstrap.sh` is **idempotent** — re-run it any time
to pick up new packages or re-link configs; steps that are already done report
`·` and change nothing.

```bash
./bootstrap.sh              # everything
./bootstrap.sh --list       # show the steps
./bootstrap.sh stow mise    # run only these steps
```

| step | does |
|---|---|
| `preflight` | checks macOS + Homebrew, and that `zsh/.zprofile` still puts brew on the login `PATH` |
| `brew` | `brew bundle` from the `Brewfile` |
| `omz` | oh-my-zsh + the four plugins `.zshrc` expects |
| `stow` | symlinks every package into `$HOME` |
| `tpm` | tmux plugin manager |
| `mise` | node, .NET SDKs, pnpm, npm CLIs, `ilspycmd` |
| `vscode` | extensions from `Brewfile.vscode` |
| `defaults` | macOS Finder/Dock/trackpad settings |

Two things the script cannot finish for you:

- **tmux plugins** — press `prefix + I` inside tmux once.
- **VS Code** — if the `vscode` step says the `code` CLI is missing, run
  *Shell Command: Install 'code' command in PATH* from the command palette,
  then `./bootstrap.sh vscode`.

## What lives here

Each top-level directory is a stow package mirroring its path under `$HOME`:

| package | links to |
|---|---|
| `btop`, `gh`, `ghostty`, `herdr`, `htop`, `karabiner`, `mise`, `nvim`, `starship` | `~/.config/<name>` |
| `git` | `~/.config/git/` — `config`, `config.work`, `ignore` |
| `ssh` | `~/.ssh/config`, `~/.ssh/1password/` |
| `1password` | `~/.config/1Password/ssh/agent.toml` |
| `ideavim` | `~/.ideavimrc` |
| `tmux` | `~/.config/tmux` |
| `zsh` | `~/.zshrc`, `~/.zshenv`, `~/.zprofile`, `~/.config/zsh` |

Adding a package: create `<name>/` with the file at its `$HOME`-relative path,
then `stow <name>`. `bootstrap.sh` discovers packages automatically, so nothing
else needs updating.

**Keep configs free of absolute paths.** `$HOME`, not `/Users/jonny` — the
whole point is that this clones onto any machine.

### Shell files and tool precedence

The three zsh files are stowed together because between them they decide which
`python3` and `node` you get, and they run in a fixed order:

| file | sourced by | does |
|---|---|---|
| `.zshenv` | **every** zsh, incl. `zsh -c` | PATH only: uv's `~/.local/bin`, rustup's `cargo/env`, mise shims |
| `.zprofile` | login zsh | `brew shellenv`, OrbStack, then re-asserts the shims |
| `.zshrc` | interactive zsh | oh-my-zsh, starship, aliases, `mise activate` |

Anything that prints, prompts, or needs a terminal belongs in `.zshrc`; the
other two are sourced by non-interactive shells where output breaks things.

`mise activate` runs in `.zshrc`, so **only interactive shells** get it. Git
hooks (husky runs `npx lint-staged` under `sh`), editor- and GUI-spawned
shells, LaunchAgents and cron get none of it, and without the shims they see no
`node`/`npx`/`pnpm` at all — plus the wrong `python3`, because both `/usr/bin`
(Xcode's 3.9) and `/opt/homebrew/bin` (python@3.14, pulled in as an azure-cli /
pipx / platformio dependency) ship one. Those are the exact interpreters
`mise/.config/mise/config.toml` exists to keep off `PATH`.

So the shims go at the **front** of `PATH`, not the back, and `.zshenv` defines
`mise-shims-first` as a function rather than a one-off export: `brew shellenv`
prepends `/opt/homebrew/bin` *after* `.zshenv` has run, so `.zprofile` has to
call it again to win. Nothing in `~/.local/bin` shares a name with a shim
(compare it against `ls ~/.local/share/mise/shims`), so this shadows nothing.
In an interactive shell `mise activate` then prepends the real install dirs
ahead of the shims, which additionally applies `[env]` vars and
`python.uv_venv_auto` that shims cannot.

Result — mise's tools in all four modes, brew's untouched:

```
zsh -c   python3 → shims/python3       3.13.14
zsh -lc  python3 → shims/python3       3.13.14   (git/stow/gh still brew's)
zsh -ic  python3 → installs/python/3.13/bin/python3
```

Shims respect project pins the same way `activate` does: inside a repo with
`.nvmrc` 22 they give node 22, outside it the global default 24.

Git config is XDG (`~/.config/git/config`), not `~/.gitconfig`. Git reads both,
with `~/.gitconfig` last and therefore winning, so keep only one — a stray
`~/.gitconfig` on a machine will silently override this package. `git config
--global` writes to `~/.config/git/config` as long as `~/.gitconfig` is absent.

`~/.config/git/ignore` is the global ignore file git reads **by default**, which
is why no `core.excludesFile` is set. A `~/.gitignore` is *not* read by default;
one used to be stowed here and had been inert for its whole life.

`gh/.config/gh/hosts.yml` holds an OAuth token and is gitignored; run
`gh auth login` on a new machine.

The `.pub` files in `ssh/.ssh/1password/` are **public** keys and are committed
deliberately — see *SSH keys and identities* below. No private key material is
in this repo; 1Password holds all of it.

## SSH keys and identities

Three keys live in 1Password, and both the key *and* the commit email are picked
automatically from the remote URL. Nothing is switched by hand.

| remote | key (1Password item) | commit email |
|---|---|---|
| `github.com/jonnyasmith/*`, everything else | `SSH Key - Ed25519` | `jonny.asmith@gmail.com` |
| `github.com/work/*` | `SSH Key - Ed25519 work` | `work@example.com` |
| `ssh.dev.azure.com` | `SSH Key - work` (RSA) | `work@example.com` |

Azure DevOps accepts **only** the RSA key; both Ed25519 keys are rejected there.

How the three pieces fit together:

- **`ssh/.ssh/config`** pins one key per host with `IdentitiesOnly yes`. Without
  it ssh offers every key in the agent and the first one the server accepts
  wins — which silently authenticated work repos as the personal account, and
  wasted two rejected attempts on every Azure connection.
- **`ssh/.ssh/1password/*.pub`** are public-key stubs. `IdentityFile` needs a
  local file to name *which* agent key to use; the private half never leaves
  1Password. Regenerate them with `~/.ssh/1password/refresh` after adding or
  renaming a key there — the item names in `agent.toml` are the map keys.
- **`git/.config/git/config`** rewrites `git@github.com:work/*` to the
  `github-work` host alias via `insteadOf`, so existing remotes and fresh
  clones both route correctly with no per-repo setup, and selects the commit
  email with `includeIf hasconfig:remote.*.url`.

Adding a second work org means one `[url]` block and one `[includeIf]` block in
`git/.config/git/config`; an unlisted org falls through to the personal key.

Two traps worth remembering:

- `hasconfig` matches the remote URL **as stored**, not as rewritten, so the
  patterns use `git@github.com:...` even though the effective URL becomes
  `git@github-work:...`.
- `**` is only wildcard-magic directly after a `/`. `...azure.com:**` matches
  nothing and fails **silently**; `...azure.com:v3/**` is correct.

Check what a repo resolved to:

```bash
git -C <repo> config user.email
git -C <repo> var GIT_AUTHOR_IDENT      # what a commit would stamp
GIT_SSH_COMMAND='ssh -v' git ls-remote origin HEAD 2>&1 | grep 'Offering public key'
```

## Packages

`Brewfile` is the source of truth for Homebrew, and `Brewfile.vscode` for
editor extensions. After installing or removing something, re-record it:

```bash
brew bundle dump --file=Brewfile --force
grep -v '^vscode ' Brewfile > t && grep '^vscode ' Brewfile > Brewfile.vscode && mv t Brewfile
```

Check for drift without changing anything:

```bash
brew bundle check --file=Brewfile    # is everything installed?
brew bundle cleanup --file=Brewfile  # what is installed but unrecorded?
```

## Dev tools (mise)

`mise` owns node, python, the .NET SDKs, pnpm, and the CLIs that used to be
`npm install -g`. Versions are declared in `mise/.config/mise/config.toml`, and
`.zshrc` runs `mise activate zsh`, so `PATH` is rewritten on `cd`.

```bash
mise install     # install everything the config declares
mise ls          # what is installed
mise outdated    # what is behind
mise upgrade     # bump tools pinned to a moving target
```

Do **not** `brew install` node, nvm, pnpm, or the `dotnet-sdk` casks — mise owns
those and a Homebrew copy will shadow it. mise sets `DOTNET_ROOT` and
`DOTNET_MULTILEVEL_LOOKUP` itself; never export them from the shell.

Per-project versions come from files already in your repos — `global.json`
(`sdk.version`), `.nvmrc` / `.node-version`, and `.python-version` — because
`idiomatic_version_file_enable_tools` is set. Entering a directory switches
automatically. mise does *not* read `package.json`'s `packageManager` field; to
pin pnpm per project use `mise use pnpm@10` or a `.tool-versions`.

### Python

Homebrew's `python@3.14` is a **dependency** of `azure-cli`, `pipx`, `pytest`
and `platformio`, so it is upgraded whenever any of those are, and every venv
built against it drifts. Leave it installed — those formulae each have a
private `libexec` venv with a hardcoded shebang, so none of them consume
`/opt/homebrew/bin/python3` and mise can own `python3` safely. Never remove
`/usr/bin/python3` either; that is Apple's and the OS uses it.

The split that keeps this stable:

| owns | what |
|---|---|
| mise | the interpreter — which `python3` you get, per directory |
| uv | per-project `.venv` and `uv tool install` |
| brew | nothing you invoke; just a dependency of the formulae above |

`python.uv_venv_auto` is on, so a project's `.venv` activates on `cd` without
`source .venv/bin/activate`. Create one with `uv venv` and mise will enter it.

Build project venvs from a mise or uv python, never a bare `python3 -m venv`
picked up from `PATH` before `mise activate` runs — that is how venvs end up
pinned to Homebrew or, worse, Xcode's 3.9.6.

To change a version, edit `mise/.config/mise/config.toml` and commit. `mise use
-g` writes through the stow symlink and preserves comments, but it **replaces**
a multi-version array — `mise use -g node@24` rewrites `node = ["24", "22"]`
down to `node = "24"`. Hand-edit anything with more than one version pinned.

### Known upstream issue: first `mise install` can drop one .NET SDK

Nothing here calls Microsoft's installer directly — mise does, internally. Its
`dotnet` backend downloads `dotnet-install.sh` into its own cache and runs it
per version, but both jobs share one cached copy of that script, so installing
`dotnet = ["10", "8"]` concurrently can leave one execing the file while the
other rewrites it:

```
Failed to install core:dotnet@8: dotnet-install.sh: Permission denied (os error 13)
```

It is a race in mise, not a config problem. `bootstrap.sh` retries
automatically; by hand, run `mise install` again and the second pass installs
the missing SDK.

## Migrating an existing mac off nvm and brew dotnet

Run the bootstrap first, confirm `mise ls` looks right, then remove the old
installs:

```bash
# nvm: ~/.nvm holds the node builds AND every `npm install -g` package,
# so let mise install those first (above) before deleting it.
rm -rf ~/.nvm

# dotnet: the casks install a root-owned pkg payload.
brew uninstall --cask dotnet-sdk dotnet-sdk@8

# Microsoft's pkg installer leaves PATH fragments the cask uninstall misses.
# (`dotnet-cli-tools` holds a literal `~/.dotnet/tools`, which path_helper
# never expands, so it was always dead — mise supplies that dir instead.)
sudo rm -f /etc/paths.d/dotnet /etc/paths.d/dotnet-cli-tools
```

`mise uninstall dotnet@<version>` only removes `sdk/<version>`, so a root left
over from an older `DOTNET_ROOT` can keep hundreds of MB of `shared/`, `packs/`
and `templates/`. Check `du -sh ~/.dotnet` and delete those subdirectories if
orphaned — keep `~/.dotnet/tools` and the sentinel files.

Verify in a **new** shell (`exec zsh`); the old one still holds the stale
`DOTNET_ROOT` and `PATH`:

```bash
type nvm                   # -> not found
which -a dotnet node       # -> only mise paths
dotnet --list-sdks
```
