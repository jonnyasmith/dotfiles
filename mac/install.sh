#!/bin/bash

echo "Configure Mac..."
source install/macosx.sh

echo "Installing dotfiles"
source install/dotfiles.sh

echo ""
echo "Installing homebrew packages..."
source install/brew.sh

# echo ""
# echo "Installing node from nvm..."
# source install/nvm.sh

# echo ""
# echo "Configuring zsh as default shell"
# chsh -s $(which zsh)

echo ""
echo "Done."
