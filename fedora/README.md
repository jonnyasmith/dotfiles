# Installation Guide

This guide will walk you through the process of downloading the git dotfiles repository.

## Configure dnf 

To configure dnf, open your terminal and run the following command:

```shell
echo "max_parallel_downloads=10" | sudo tee /etc/dnf/dnf.conf --append
echo "fastestmirror=true" | sudo tee /etc/dnf/dnf.conf --append
```

## Update system

To update your system, open your terminal and run the following command:

```shell
sudo dnf update && sudo dnf upgrade -y
```

## Install 1Password

To install 1Password, open your terminal and run the following command:

```shell
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
```

Then run the following commands:

```shell
dnf check-update
sudo dnf install 1password
```

Register 1Password with your account, configure SSH and you're good to go.

## Install base packages

To install base packages, open your terminal and run the following command:

```shell
sudo dnf install zig -y
sudo dnf install zsh -y
```

## Install oh-my-zsh

To install oh-my-zsh, open your terminal and run the following command:

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Install Nerd font

To install nerd font, open your terminal and run the following command:

```shell
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/officialrajdeepsingh/nerd-fonts-installer/main/install.sh)"
```

## Install starship prompt

To install starship, open your terminal and run the following command:

```shell
curl -sS https://starship.rs/install.sh | sh
```

To install nvm, open your terminal and run the following command:

```shell
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash 
```

## Clone dotfiles repository and install

To download the dotfiles repository, open your terminal and run the following command:

```shell
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
```

To install the dotfiles, open your terminal and run the following command:

```shell
cd ~/.dotfiles/linux && sudo bash install.sh
```

## Install oh-my-zsh

To install oh-my-zsh, open your terminal and run the following command:

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Install oh-my-zsh plugins

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete
git clone https://github.com/olets/zsh-abbr.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-abbr 

```

## Install Starship prompt

To install starship, open a terminal and run the following command:

```shell
curl -sS https://starship.rs/install.sh | sh
```

## Install nvm

To install nvm, open your terminal and run the following command:

```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```
