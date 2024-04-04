#!/bin/bash

echo ""
echo "Installing packages..."
source install/packages.sh

echo "Configure Linux..."
source install/linux.sh

echo ""
echo "Symlinking dotfiles..."
source install/links.sh


echo ""
echo "Done."
