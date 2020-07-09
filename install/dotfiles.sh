#!/bin/bash

mkdir -p ~/.dotfiles
cd ~/.dotfiles
if [ ! -d ~/.dotfiles ]; then
    echo "Cloning dotfiles repo"
    git clone https://github.com/jonnyasmith/dotfiles
else
    echo "Updating dotfiles repo"
fi