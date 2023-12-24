# Installation Guide

This guide will walk you through the process of installing winget and downloading the git dotfiles repository.

## Install all Windows updates

To install all Windows updates, open the Windows Settings app and navigate to Update & Security > Windows Update > Check for updates.

## Set powershell execution policy

Grant full disk access to Terminal in System Preferences > Security & Privacy > Privacy > Full Disk Access. Search for Terminal in the utilities folder and check the box.

```powershell
# run with elevated privileges
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```

## Install winget and git

To install winget, go to the following website and select install link.

[Winget installl guile](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

Restart you terminal and run the following command to install git:

```powershell
# run with elevated privileges
winget install --id Git.Git
```

## Create new SSH Key

To create a GitHub SSH key, open your terminal and run the following command:

```shell
# run without elevated privileges
ssh-keygen -t ed25519 -C "jonny.smith@digitaljs.com"
```

Run the following command to start the ssh-agent in the background:

```powershell
# run without elevated privileges
Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service
```

Create a config file in the ~/.ssh directory:

```powershell
# run without elevated privileges
New-Item -Path "$env:USERPROFILE\.ssh" -Name "config" -ItemType File
```

Run the following command to add your SSH key to the ssh-agent:

```powershell
# run without elevated privileges
ssh-add "$env:USERPROFILE\.ssh\id_ed25519"
```

Run the following command to copy the SSH key to your clipboard:

```powershell
# run without elevated privileges
cat $HOME\.ssh\id_ed25519.pub | clip
```

Log in to your GitHub account and navigate to the SSH and GPG keys section of your account settings.

## Clone dotfiles repository and install

To download the dotfiles repository, open your terminal and run the following command:

```sh
# run without elevated privileges
git clone git@github.com:jonnyasmith/dotfiles.git "$env:USERPROFILE\.dotfiles"
```

To install the dotfiles, open your terminal with elevated privileges and run the following command:

```powershell
# run with elevated privileges
cd "$env:USERPROFILE\.dotfiles\windows" ; .\install.ps1
```

Run post-installation steps:

```powershell
# run with elevated privileges
cd "$env:USERPROFILE\.dotfiles\windows" ; .\post-install.ps1
```

## Install debian wsl

To install debian wsl, open your terminal and run the following command:

```powershell
# run with elevated privileges
wsl --install --distribution Debian
```

update debian packages:

```bash
sudo apt-get update && apt-get upgrade -y
```

## Setup nvim

To setup nvim, open your terminal and run the following command:

```powershell
# run without elevated privileges
nvim
:PackerInstall
```
