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

## install docker engine

To install the docker engine, open your terminal and run the following command:

```shell
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

to install the latest version of docker engine, run the following command:

```shell
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

to remove the need to use sudo when running docker commands, run the following command:

```shell
sudo usermod -aG docker $USER
```

logout and log back in to apply the changes

## grant permissions to the /opt directory

```shell
sudo chown -R jonny /opt
```
