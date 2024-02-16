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

for package in "${packages_to_install[@]}"; do
    if ! dnf list installed "$package" > /dev/null 2>&1; then
        echo "Installing $package..."
        sudo dnf install -y $package
    else
        echo "$package is already installed."
    fi
done

if ! dnf list installed terraform > /dev/null 2>&1; then
    echo "Installing terraform..."
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf -y install terraform
else
    echo "terraform is already installed."
fi
