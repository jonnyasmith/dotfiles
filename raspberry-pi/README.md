# Installation Guide

This guide will walk you through the process of installing the git dotfiles repository.

## Install all debain updates

To install all debian updates, open your terminal and run the following command:

```bash
sudo apt update && sudo apt upgrade -y
```

## Install git

To install git, open your terminal and run the following command:

```bash
sudo apt install git -y
```

## Create new SSH Key

To create a GitHub SSH key, open your terminal and run the following command:

```shell
# run without elevated privileges
ssh-keygen -t ed25519 -C "jonny.asmith@gmail.com"
```

## Add SSH Key to ssh-agent

Run the following command to start the ssh-agent in the background:

```shell
# run without elevated privileges
eval "$(ssh-agent -s)"
```

Run the following command to add your SSH key to the ssh-agent:

```shell
# run without elevated privileges
ssh-add ~/.ssh/id_ed25519
```

Run the following command to copy the SSH key to your clipboard:

```shell
# run without elevated privileges
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard
```

## Clone dotfiles repository and install

To download the dotfiles repository, open your terminal and run the following command:

```shell
# run without elevated privileges
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
```

To install the dotfiles, open your terminal and run the following command:

```shell
# run without elevated privileges
cd ~/.dotfiles/raspberry-pi && sudo bash ./install.sh
```


## grant permissions to the /opt directory

```shell
sudo chown -R jonny /opt
```
