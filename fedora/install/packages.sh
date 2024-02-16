#!/bin/bash

# List of packages to install (add or remove packages as needed)
packages_to_install=(
  azure-cli
  code
  curl
  dotnet-sdk-6.0
  dotnet-sdk-7.0
  dotnet-sdk-8.0
  fzf
  gnome-tweaks
  htop
  neovim
  python3-neovim
  tree
  vlc
  zsh
)

# Install packages
for package in "${packages_to_install[@]}"; do
    sudo dnf install -y $package
done
