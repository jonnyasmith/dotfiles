# Installation Guide

This guide will walk you through the process of installing winget and downloading the git dotfiles repository.

## Install all Windows updates

To install all Windows updates, open the Windows Settings app and navigate to Update & Security > Windows Update > Check for updates.

## Install packages

```powershell
winget install --id AgileBits.1Password
winget install --id CoreyButler.NVMforWindows
winget install --id Git.Git
winget install --id JetBrains.Toolbox
winget install --id Microsoft.AzureCLI
winget install --id Microsoft.DotNet.SDK.8
winget install --id Microsoft.PowerShell
winget install --id Microsoft.VisualStudioCode
winget install --id Neovim.Neovim
winget install --id Starship.Starship
winget install --id junegunn.fzf
winget install --id zig.zig
winget install --id RandyRants.SharpKeys
```

## Install Packer

```powershell
git clone https://github.com/wbthomason/packer.nvim $env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim
```

## Install Nerd Font

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/amnweb/nf-installer/main/install.ps1'))
```

## Clone dotfiles

```sh
# run without elevated privileges
git clone git@github.com:jonnyasmith/dotfiles.git "$env:USERPROFILE\.dotfiles"
```

```powershell
# run with elevated privileges
wsl --install --distribution Debian
```
