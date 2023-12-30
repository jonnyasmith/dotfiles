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

## Clone dotfiles repository and install

To download the dotfiles repository, open your terminal and run the following command:

```shell
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
```

To install the dotfiles, open your terminal and run the following command:

```shell
cd ~/.dotfiles/mac && sh install.sh
```
