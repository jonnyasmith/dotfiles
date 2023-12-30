# Installation Guide

This guide will walk you through the process of downloading the git dotfiles repository.


## Update system and install git

To update your system and install git, open your terminal and run the following command:

```shell
sudo apt update && sudo apt upgrade -y && sudo apt install git -y
```

## Create new SSH Key

To create a GitHub SSH key, open your terminal and run the following command:

```shell
ssh-keygen -t ed25519 -C "jonny.smith@digitaljs.com"
```

Run the following command to start the ssh-agent in the background:

```shell
eval "$(ssh-agent -s)"
```

Create a config file in the ~/.ssh directory:

```shell
touch ~/.ssh/config
```

Run the following command to add your SSH key to the ssh-agent:

```shell
ssh-add ~/.ssh/id_ed25519
```

Run the following command to copy the SSH key to your clipboard:

```shell
cat  ~/.ssh/id_ed25519.pub
```

Log in to your GitHub account and navigate to the SSH and GPG keys section of your account settings.

## Install Zig

To install zig, open your terminal and run the following command:

```shell
sudo snap install zig --beta --classic
```

## Install Nerd font

To install nerd font, open your terminal and run the following command:

```shell
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/officialrajdeepsingh/nerd-fonts-installer/main/install.sh)"
```

## Install nvm 

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
```

## Install Starship prompt

To install starship, open a terminal and run the following command:

```shell
curl -sS https://starship.rs/install.sh | sh
```