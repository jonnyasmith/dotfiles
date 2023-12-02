#!/bin/bash

mkdir -p ~/.dotfiles
cd ~/.dotfiles
if [[ ! -d dotfiles ]]; then
    printf "Cloning dotfiles repo\n"
    git clone https://github.com/jonnyasmith/dotfiles
    cd dotfiles
else
    printf "Updating dotfiles repo\n"
    git pull
fii