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
