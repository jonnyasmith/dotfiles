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
3. **Sign in to 1Password** and enable the SSH agent, so git can reach GitHub:
   ```bash
   ssh -T git@github.com   # should greet you by username
   ```

Then clone and run:

```bash
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && git checkout mac
./bootstrap.sh
exec zsh
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
| `preflight` | checks macOS + Homebrew, puts brew on the login `PATH` |
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
| `git` | `~/.gitconfig`, `~/.gitignore` |
| `ideavim` | `~/.ideavimrc` |
| `tmux` | `~/.config/tmux` |
| `zsh` | `~/.zshrc`, `~/.config/zsh` |

Adding a package: create `<name>/` with the file at its `$HOME`-relative path,
then `stow <name>`. `bootstrap.sh` discovers packages automatically, so nothing
else needs updating.

**Keep configs free of absolute paths.** `$HOME`, not `/Users/jonny` — the
whole point is that this clones onto any machine.

`gh/.config/gh/hosts.yml` holds an OAuth token and is gitignored; run
`gh auth login` on a new machine.

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

`mise` owns node, the .NET SDKs, pnpm, and the CLIs that used to be
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
(`sdk.version`) and `.nvmrc` / `.node-version` — because
`idiomatic_version_file_enable_tools` is set. Entering a directory switches
automatically. mise does *not* read `package.json`'s `packageManager` field; to
pin pnpm per project use `mise use pnpm@10` or a `.tool-versions`.

To change a version, edit `mise/.config/mise/config.toml` and commit. `mise use
-g` writes through the stow symlink and preserves comments, but it **replaces**
a multi-version array — `mise use -g node@24` rewrites `node = ["24", "22"]`
down to `node = "24"`. Hand-edit anything with more than one version pinned.

### Known upstream issue

Installing both .NET SDKs concurrently can fail one with
`dotnet-install.sh: Permission denied (os error 13)` — they share a single
cached copy of Microsoft's install script. `bootstrap.sh` retries automatically;
by hand, just run `mise install` again.

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
