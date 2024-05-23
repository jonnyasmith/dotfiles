# WSL Dotfiles

This repository contains setup scripts to configure your WSL environment with essential tools and configurations.

## Prerequisites

Make sure you have WSL installed and set up on your Windows machine.

## Setup Script

Run the following commands to set up your environment:

```bash
sudo apt update && sudo apt install -y git nala
sudo nala upgrade -y
sudo nala install -y curl fzf git unzip wget zsh stow tmux xz-utils
git config --global core.sshCommand ssh.exe
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git checkout wsl
curl -sS https://starship.rs/install.sh | sh
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
nvm install --lts
npm install prettier -g
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz
curl -LO https://ziglang.org/download/0.12.0/zig-linux-x86_64-0.12.0.tar.xz
sudo rm -rf /opt/zig
tar -xf ./zig-linux-x86_64-0.12.0.tar.xz
sudo mv zig-linux-x86_64-0.12.0 /opt/zig
rm zig-linux-x86_64-0.12.0.tar.xz
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Post-Setup Script

Run the following commands to complete the setup:

```bash
sh ~/dotfiles/scripts/zsh.sh
mkdir ~/.config
rm ~/.zshrc ~/.gitconfig
stow .
source ~/.zshrc
```

## Docker Setup

To install Docker and set up Portainer, run the following command:

```bash
sh ~/dotfiles/scripts/docker.sh
```

## Additional Information

- The setup script installs essential tools such as curl, fzf, git, unzip, wget, zsh, stow, tmux, and xz-utils.
- Git is configured to use ssh.exe for SSH commands.
- The dotfiles repository is cloned, and the wsl branch is checked out.
- The Starship prompt, NVM, Node.js (LTS), and Prettier are installed.
- Neovim and Zig are downloaded and installed in /opt.
- Oh My Zsh is installed for a better Zsh experience.
