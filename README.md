# WSL dotfiles

to setup wsl, run the following commands:

```bash
wsl --install -d Debian
```

update and upgrade the system

```bash
sudo apt update && sudo apt install -y git nala
sudo nala upgrade -y
sudo nala install -y curl fzf git unzip wget zsh stow tmux
git config --global core.sshCommand ssh.exe
git clone git@github.com:jonnyasmith/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git checkout wsl
curl -sS https://starship.rs/install.sh | sh
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

```bash
mkdir ~/.config
rm ~/.zshrc ~/.gitconfig
stow .
```

