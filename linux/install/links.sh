#!/bin/bash

echo "Symlinking starship.toml..."
ln -sf /home/jonny/.dotfiles/config/starship.toml /home/jonny/.config/starship.toml

echo "Symlinking nvim..."
ln -sf /home/jonny/.dotfiles/config/nvim /home/jonny/.config/nvim

echo "Symlinking zsh..."
ln -sf /home/jonny/.dotfiles/config/zsh /home/jonny/.config/zsh

echo "Symlinking gitconfig..."
ln -sf /home/jonny/.dotfiles/linux/git/gitconfig.symlink /home/jonny/.gitconfig

echo "Symlinking zshrc..."
ln -sf /home/jonny/.dotfiles/config/.zshrc /home/jonny/.zshrc