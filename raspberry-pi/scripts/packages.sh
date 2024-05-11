#!/bin/bash

sudo apt install -y \
  htop \
  tree \
  curl \
  wget \
  fzf \
  zsh

curl -sS https://starship.rs/install.sh | sh

if ! which starship >/dev/null 2>&1; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh
else
    echo "Starship already installed."
fi
