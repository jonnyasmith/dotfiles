#!/bin/bash

echo "Configure Mac..."
source install/macosx.sh

echo "Installing dotfiles"
source install/dotfiles.sh

echo ""
echo "Installing homebrew packages..."
source install/brew.sh

echo ""
echo "Done."
