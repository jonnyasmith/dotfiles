#!/bin/bash

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

echo "Configure Linux..."

echo ""
echo "Symlinking dotfiles..."

echo ""
echo "Installing packages..."
source install/linux.sh

echo ""
echo "Install OH-MY-ZSH..."

echo ""
echo "Done."
