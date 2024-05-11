#!/bin/bash

echo "Configure Linux..."
source scripts/linux.sh

echo ""
echo "Installing packages..."
source scripts/packages.sh

echo ""
echo "Install OH-MY-ZSH..."
source scripts/zsh.sh

echo ""
echo "Symlinking dotfiles..."
source scripts/links.sh

echo ""
echo "Done."
