#!/bin/bash

# Check if apt is installed
if ! which apt &> /dev/null
then
    printf "apt could not be found\n"
    exit
fi

# Update the package list and upgrade installed packages
echo "Updating packages..."
sudo apt update
sudo apt upgrade -y

# List of packages to install (add or remove packages as needed)
packages_to_install=(
  curl
  fzf
  tree
  wget
  zsh
)

# Install packages
for package in "${packages_to_install[@]}"; do
  if dpkg-query -W -f='${Status}' $package 2>/dev/null | grep -q "install ok installed"; then
    echo "$package is already installed."
  else
    sudo apt install -y $package
  fi
done
