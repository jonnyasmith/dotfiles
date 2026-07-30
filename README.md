# Mac Setup

This repository contains setup scripts and dotfiles to configure your MAC environment with essential tools and configurations.

## Update operating system

```bash
sudo softwareupdate -i -a
```

## Install Homebrew

Homebrew is a package manager for macOS that simplifies the installation of software.

To install Homebrew, open your terminal and run the following command:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add brew to your PATH in ~/.zprofile:

```shell
echo >> /Users/jonny/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/jonny/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Install pre setup applications

Run the following commands to set up your environment:

```bash
brew install git stow zsh fzf jq neovim starship tree zoxide tmux mise curl wget lazygit
brew install --cask 1password visual-studio-code rectangle
```

## Setup 1password ssh agent and download dotfiles

```bash
ssh -T git@github.com
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
cd .dotfiles
git checkout mac
```

## Stow dotfiles

Run the following commands to symlink configuration files

```bash
rm ~/.zshrc
cd ~/.dotfiles
stow git
stow ideavim
stow mise
stow nvim
stow starship
stow tmux
stow zsh
```

## Install oh-my-zsh

To install oh-my-zsh, and plugins:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Clone the zsh-syntax-highlighting plugin into the Oh My Zsh custom plugins directory
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Clone the fast-syntax-highlighting plugin into the Oh My Zsh custom plugins directory
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

# Clone the zsh-autocomplete plugin into the Oh My Zsh custom plugins directory with a shallow clone
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
```

## Install tmux plugin

To install tpm

```bash
# Clone the tmux plugin manager (tpm) into the .tmux/plugins directory
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Install dev tools with mise

`mise` replaces `nvm` (node) and the Homebrew `dotnet-sdk` casks. It was
installed by `brew install` above, and `stow mise` symlinked
`~/.config/mise/config.toml`, which declares every version. `.zshrc` runs
`mise activate zsh`, so `PATH` is rewritten on `cd`.

Install everything the config declares:

```bash
mise install
mise ls
```

If one of the two .NET SDKs fails with `dotnet-install.sh: Permission denied
(os error 13)`, that is an upstream race: both versions install concurrently
and share a single cached copy of Microsoft's install script, so one execs it
while the other is rewriting it. Just run `mise install` again — the second
pass installs the missing version.

That provides the .NET SDKs, node, pnpm, and the `npm:` CLIs (copilot,
gemini-cli, firebase-tools, azure-functions-core-tools, cline, kanban, ...).

Do **not** `brew install` node, nvm, pnpm, or the `dotnet-sdk` casks — mise owns
those, and a Homebrew copy will shadow or fight it. `mise` sets `DOTNET_ROOT`
and `DOTNET_MULTILEVEL_LOOKUP=0` itself, so never export them from the shell.

.NET SDKs install side-by-side into one shared root, so `dotnet --list-sdks`
shows every installed version and multi-targeting works without switching:

```bash
dotnet --list-sdks
```

Per-project versions come from the files already in the repo — `global.json`
(`sdk.version`) and `.nvmrc` / `.node-version` — because
`idiomatic_version_file_enable_tools` is set. Entering a directory switches
automatically; no `nvm use`.

To change a version, edit `mise/.config/mise/config.toml` directly and commit
it. `mise use -g` also writes through the stow symlink (comments survive), but
it **replaces** a multi-version array — `mise use -g node@24` rewrites
`node = ["24", "22"]` down to `node = "24"` and drops node 22. Prefer editing
the file by hand for any tool with more than one version pinned.

```bash
mise upgrade               # bump `latest` tools
mise outdated              # report without applying
```

### .NET global tools

`dotnet tool install --global` targets `~/.dotnet/tools`, which is separate from
the SDK root and therefore not managed by mise. Reinstall those by hand:

```bash
dotnet tool install --global ilspycmd
```

### Migrating an existing mac off nvm and brew dotnet

On a machine that already had `nvm` and the `dotnet-sdk` casks, do the above
first, confirm `mise ls` looks right, then remove the old installs:

```bash
# nvm: ~/.nvm holds the node builds AND every `npm install -g` package,
# so reinstall those through mise (above) before deleting it.
rm -rf ~/.nvm

# dotnet: the casks install a root-owned pkg payload, so this needs sudo.
brew uninstall --cask dotnet-sdk dotnet-sdk@8

# Microsoft's pkg installer leaves PATH fragments the cask uninstall misses.
# (`dotnet-cli-tools` holds a literal `~/.dotnet/tools`, which path_helper
# never expands, so it was always dead — mise supplies that dir instead.)
sudo rm -f /etc/paths.d/dotnet /etc/paths.d/dotnet-cli-tools
```

`mise uninstall dotnet@<version>` only removes `sdk/<version>`, so a root left
over from an older `DOTNET_ROOT` can keep hundreds of MB of `shared/`, `packs/`
and `templates/`. Check with `du -sh ~/.dotnet` and delete those subdirectories
if they are orphaned; keep `~/.dotnet/tools` and the sentinel files.

Verify in a **new** shell (`exec zsh`), since the old one still has the stale
`DOTNET_ROOT` and `PATH`:

```bash
type nvm                   # -> not found
which -a dotnet node       # -> only mise paths
dotnet --list-sdks
```

## Install software

```bash
brew install --cask alfred docker font-fira-mono-nerd-font google-chrome iterm2 jetbrains-toolbox karabiner-elements miro
```

## Install Nerd font

To install nerd font, open your terminal and run the following command:

```bash
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/officialrajdeepsingh/nerd-fonts-installer/main/install.sh)"
```

## Configure Mac settings

Run the following commands to configure your Mac settings:

```bash
    # echo "Finder: show all filename extensions"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # echo "Automatically hide and show the Dock"
    defaults write com.apple.dock autohide -bool true

    # echo "Use current directory as default search scope in Finder"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # echo "Show Status bar in Finder"
    defaults write com.apple.finder ShowStatusBar -bool true

    # echo "Disable the warning when changing a file extension"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # echo "Disable the warning before emptying the Trash"
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    # echo "Empty Trash securely by default"
    defaults write com.apple.finder EmptyTrashSecurely -bool true

    # echo "Enable tap to click (Trackpad)"
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    # echo "Restarting system apps"
    killall Finder
    Killall Dock
```
