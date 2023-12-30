#!/bin/bash

# Check if apt is installed
if ! which apt &> /dev/null
then
    printf "apt could not be found\n"
    exit
fi

# Update the package list and upgrade installed packages
echo "Updating packages..."
apt update
sudo apt upgrade -y

# Enable firewall
echo "Enabling firewall..."
ufw enable

if [ ! -d "/home/jonny/.local/share/nvim/site/pack/packer/start/packer.nvim" ] ; then
    git clone https://github.com/wbthomason/packer.nvim /home/jonny/.local/share/nvim/site/pack/packer/start/packer.nvim
fi