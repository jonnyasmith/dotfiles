#!/bin/bash

sudo apt install -y \
  htop \
  tree \
  curl \
  wget \
  fzf \
  zsh

curl -sS https://starship.rs/install.sh | sh

if ! which starship &> /dev/null
then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh
fi
