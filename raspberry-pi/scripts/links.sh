#!/bin/bash

echo "Symlinking starship..."
ln -sf /home/jonny/.dotfiles/raspberry-pi/dotfiles/starship.toml /home/jonny/.config/starship.toml

echo "Symlinking gitconfig..."
ln -sf /home/jonny/.dotfiles/raspberry-pi/dotfiles/.gitconfig /home/jonny/.gitconfig

echo "Symlinking zshrc..."
ln -sf /home/jonny/.dotfiles/raspberry-pi/dotfiles/.zshrc /home/jonny/.zshrc
