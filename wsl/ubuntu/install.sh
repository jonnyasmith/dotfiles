#!/bin/bash

echo "Configure Linux..."
source install/linux.sh

# echo ""
# echo "Symlinking dotfiles..."
# source install/links.sh

echo ""
echo "Installing packages..."
source install/packages.sh

echo ""
echo "Done."
