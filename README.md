# WSL dotfiles

Setup script

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

Post setup script

```bash
sh scripts/zsh.sh
mkdir ~/.config
rm ~/.zshrc ~/.gitconfig
stow .
source ~/.zshrc
```

Docker setup

```bash
sh ~/.dotfiles/scripts/docker.sh
```
