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
brew install git stow zsh fzf jq neovim starship tree zoxide tmux pnpm curl wget
brew install --cask 1password visual-studio-code
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

## install nvm

To install nvm, run the following command:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
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
