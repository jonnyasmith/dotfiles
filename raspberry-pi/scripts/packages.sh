#!/bin/bash

sudo apt install -y \
  htop \
  tree \
  curl \
  wget \
  fzf \
  zsh

curl -sS https://starship.rs/install.sh | sh

if [ ! -f /usr/local/bin/starship ]; then
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh
fi
