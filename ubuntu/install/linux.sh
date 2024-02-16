#!/bin/bash

# Check if apt is installed
if ! which dnf &> /dev/null
then
    printf "dnf could not be found\n"
    exit
fi

# Update the package list and upgrade installed packages
echo "Updating packages..."
sudo dnf update
sudo dnf upgrade -y

if [ ! -d "/home/jonny/.local/share/nvim/site/pack/packer/start/packer.nvim" ] ; then
    git clone https://github.com/wbthomason/packer.nvim /home/jonny/.local/share/nvim/site/pack/packer/start/packer.nvim
fi
