#!/bin/bash

echo "Symlinking gitconfig..."
ln -sf /home/jonny/.dotfiles/raspberry-pi/dotfiles/.gitconfig /home/jonny/.gitconfig

echo "Symlinking zshrc..."
ln -sf /home/jonny/.dotfiles/raspberry-pi/dotfiles/.zshrc /home/jonny/.zshrc
