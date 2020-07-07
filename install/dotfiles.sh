#!/bin/bash

mkdir -p ~/.dotfiles
cd ~/.ditfiles
if [ ! -d ~/.dotfiles ]; then
    echo "Cloning dotfiles repo"
    git clone https://github.com/StefanScherer/dotfiles
else
    echo "Updating dotfiles repo"
fi