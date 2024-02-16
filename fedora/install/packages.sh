#!/bin/bash

# List of packages to install (add or remove packages as needed)
packages_to_install=(
  gnome-tweaks
  code
  htop
  tree
  vlc
  curl
  fzf
  zsh
  dotnet-sdk-6.0
  dotnet-sdk-7.0
  dotnet-sdk-8.0
  neovim
  python3-neovim
  azure-cli
)

# Install packages
for package in "${packages_to_install[@]}"; do
    sudo dnf install -y $package
done
