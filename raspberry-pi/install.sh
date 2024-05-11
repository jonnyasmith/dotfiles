#!/bin/bash

echo "Configure Linux..."
source scripts/linux.sh

# echo ""
# echo "Symlinking dotfiles..."
# source install/links.sh

echo ""
echo "Installing packages..."
source scripts/packages.sh

echo ""
echo "Install OH-MY-ZSH..."
source scripts/zsh.sh

echo ""
echo "Done."
