# WSL Dotfiles

This repository contains setup scripts to configure your WSL environment with essential tools and configurations.

## Prerequisites

Make sure you have WSL installed and set up on your Windows machine.

## Setup Script

Run the following commands to set up your environment:

```bash
sudo apt install -y curl
curl https://raw.githubusercontent.com/jonnyasmith/dotfiles/wsl/scripts/setup.sh | bash
```

## Post-Setup Script

Run the following commands to complete the setup:

```bash
cd ~/.dotfiles
curl https://raw.githubusercontent.com/jonnyasmith/dotfiles/wsl/scripts/post-setup.sh | bash
```

## Docker Setup

To install Docker and set up Portainer, run the following command:

```bash
sh ~/.dotfiles/scripts/docker.sh
```

## Additional Information

- The setup script installs essential tools such as curl, fzf, git, unzip, wget, zsh, stow, tmux, and xz-utils.
- Git is configured to use ssh.exe for SSH commands.
- The dotfiles repository is cloned, and the wsl branch is checked out.
- The Starship prompt, NVM, Node.js (LTS), and Prettier are installed.
- Neovim and Zig are downloaded and installed in /opt.
- Oh My Zsh is installed for a better Zsh experience.
