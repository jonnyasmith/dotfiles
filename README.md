# WSL Dotfiles

This repository contains setup scripts to configure your WSL environment with essential tools and configurations.

## Prerequisites

Make sure you have WSL installed and set up on your Windows machine.

## Setup Script

Run the following commands to set up your environment:

```bash
# Update package lists and install git and nala
sudo apt update && sudo apt install -y git nala

# Upgrade installed packages using nala
sudo nala upgrade -y

# Install essential packages using nala
sudo nala install -y curl fzf git unzip wget zsh stow tmux xz-utils

# Configure git to use ssh.exe for SSH commands
git config --global core.sshCommand ssh.exe

# Clone the dotfiles repository from GitHub to the .dotfiles directory
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles

# Navigate to the .dotfiles directory
cd ~/.dotfiles

# Checkout the wsl branch in the dotfiles repository
git checkout wsl

# Install Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Install NVM (Node Version Manager)
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

# Download and install the latest version of Neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

# Download and install the specified version of Zig
curl -LO https://ziglang.org/download/0.12.0/zig-linux-x86_64-0.12.0.tar.xz
sudo rm -rf /opt/zig
tar -xf ./zig-linux-x86_64-0.12.0.tar.xz
sudo mv zig-linux-x86_64-0.12.0 /opt/zig
rm zig-linux-x86_64-0.12.0.tar.xz

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Post-Setup Script

Run the following commands to complete the setup:

```bash
# Run the zsh.sh script from the scripts directory to set up Zsh environment
sh ~/.dotfiles/scripts/zsh.sh

# Create a .config directory in the user's home directory
mkdir ~/.config

# Remove existing .zshrc and .gitconfig files from the home directory
rm ~/.zshrc ~/.gitconfig

# Use stow to symlink the dotfiles from the repository to the appropriate locations
stow .

# Source the new .zshrc file to apply the Zsh configuration immediately
source ~/.zshrc
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
