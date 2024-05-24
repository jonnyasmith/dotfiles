# WSL Setup

[Ubuntu Installation Guide](ubuntu.md)

This repository contains setup scripts to configure your WSL environment with essential tools and configurations.

## Prerequisites

Ensure you have WSL installed and set up on your Windows machine. You can install WSL by following the [Microsoft WSL Installation Guide.](https://learn.microsoft.com/en-us/windows/wsl/install)

## Setup Script

Run the following commands to set up your environment:

```bash
# Update package lists and install git and nala
sudo apt update && sudo apt install -y git nala

# Upgrade installed packages using nala
sudo nala upgrade -y

# Install essential packages using nala
sudo nala install -y curl fzf git unzip wget zsh stow tmux tree xz-utils

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

After running the setup script, execute the following commands to complete the configuration:

```bash
# Clone the zsh-autosuggestions plugin into the Oh My Zsh custom plugins directory
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Clone the zsh-syntax-highlighting plugin into the Oh My Zsh custom plugins directory
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Clone the fast-syntax-highlighting plugin into the Oh My Zsh custom plugins directory
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting

# Clone the zsh-autocomplete plugin into the Oh My Zsh custom plugins directory with a shallow clone
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete

# Clone the tmux plugin manager (tpm) into the .tmux/plugins directory
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Create a .config directory in the user's home directory if it doesn't exist
mkdir ~/.config

# Backup existing .zshrc file by renaming it to .zshrc.orig
mv ~/.zshrc ~/.zshrc.orig

# Backup existing .gitconfig file by renaming it to .gitconfig.orig
mv ~/.gitconfig ~/.gitconfig.orig

# Use stow to symlink the dotfiles from the repository to the appropriate locations in the home directory
stow .

# Source the new .zshrc file to apply the Zsh configuration immediately
source ~/.zshrc
```

## Docker Setup

To install Docker, run the following command:

```bash
# Update the package lists and install necessary packages
sudo nala update
sudo nala install ca-certificates curl

# Create the directory for the Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's official GPG key and save it to the created directory
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc

# Set permissions for the Docker GPG key
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to the Apt sources list
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package lists again to include the new Docker repository
sudo nala update

# Install Docker packages
sudo nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the current user to the Docker group to allow running Docker commands without sudo
sudo usermod -aG docker $USER

# Start the Docker service automatically
sudo tee /etc/wsl.conf > /dev/null <<EOF
[boot]
command="service docker start"
EOF

# Start the Docker service manually
sudo service docker start
```

### Portainer Setup

To set up Portainer, run the following command:

```bash
# Create a directory for Portainer
sudo mkdir /opt/portainer

# Create a Docker Compose file for Portainer
sudo tee /opt/portainer/docker-compose.yml > /dev/null <<EOF
services:
  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    restart: always
    ports:
      - "9000:9000"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "/opt/portainer/data:/data"
EOF

# Navigate to the Portainer directory
cd /opt/portainer

# Use Docker Compose to start Portainer in detached mode
sudo docker compose up -d

# Return to the previous directory
cd
```

## Additional Information

- The setup script installs essential tools such as curl, fzf, git, unzip, wget, zsh, stow, tmux, and xz-utils.
- Git is configured to use ssh.exe for SSH commands.
- The dotfiles repository is cloned, and the wsl branch is checked out.
- The Starship prompt, NVM, Node.js (LTS), and Prettier are installed.
- Neovim and Zig are downloaded and installed in /opt.
- Oh My Zsh is installed for a better Zsh experience.

Ensure to follow the steps sequentially for a smooth setup process. If you encounter any issues, check the documentation of each tool for troubleshooting tips.
