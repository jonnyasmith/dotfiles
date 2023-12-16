# Installation Guide

This guide will walk you through the process of installing winget and downloading the git dotfiles repository.

## Set powershell execution policy

Grant full disk access to Terminal in System Preferences > Security & Privacy > Privacy > Full Disk Access. Search for Terminal in the utilities folder and check the box.

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```

## Create new SSH Key

To create a GitHub SSH key, open your terminal and run the following command:

```shell
ssh-keygen -t ed25519 -C "jonny.smith@digitaljs.com"
```

Run the following command to start the ssh-agent in the background:

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service
```

Create a config file in the ~/.ssh directory:

```powershell
New-Item -Path "$env:USERPROFILE\.ssh" -Name "config" -ItemType File
```

Run the following command to add your SSH key to the ssh-agent:

```powershell
ssh-add "$env:USERPROFILE\.ssh\id_ed25519"
```

Run the following command to copy the SSH key to your clipboard:

```powershell
cat $HOME\.ssh\id_ed25519.pub | clip
```

Log in to your GitHub account and navigate to the SSH and GPG keys section of your account settings.

## Clone dotfiles repository and install

To download the dotfiles repository, open your terminal and run the following command:

```sh
git clone git@github.com:jonnyasmith/dotfiles.git "$env:USERPROFILE\.dotfiles"
```

To install the dotfiles, open your terminal with elevated privileges and run the following command:

```powershell
cd "$env:USERPROFILE\.dotfiles\windows" ; .\install.ps1
```
