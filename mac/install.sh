#!/bin/bash

echo "Configure Mac..."
source install/macosx.sh

echo ""
echo "Installing homebrew packages..."
source install/brew.sh

echo ""
echo "Symlinking dotfiles..."
source install/link.sh

echo ""
echo "Done."
