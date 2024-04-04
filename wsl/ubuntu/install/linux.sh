#!/bin/bash

if [ ! -d "/home/jonny/.local/share/nvim/site/pack/packer/start/packer.nvim" ] ; then
    git clone https://github.com/wbthomason/packer.nvim /home/jonny/.local/share/nvim/site/pack/packer/start/packer.nvim
fi

if ! which starship &> /dev/null
then
    curl -sS https://starship.rs/install.sh | sh
else
    echo "Starship is already installed"
fi
