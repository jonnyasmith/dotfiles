#!/bin/bash

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
  if sudo dpkg -l | grep -q $package; then
    echo "$package is already installed."
  else
    sudo apt install -y $package
  fi
done
