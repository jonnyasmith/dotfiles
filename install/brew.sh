#!/bin/sh

if test ! $(which brew); then
    echo "Installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Installing homebrew packages..."

# cli tools
echo ""
echo "Installing ack"
brew install ack
echo ""
echo "Installing tree"
brew install tree
echo ""
echo "Installing wget"
brew install wget

# development tools
echo ""
echo "Installing git"
brew install git
echo ""
echo "Installing hub"
brew install hub
#echo ""
#echo "Installing macvim"
#brew install macvim --override-system-vim
echo ""
echo "Installing reattach-to-user-namespace"
brew install reattach-to-user-namespace
echo ""
echo "Install tmux"
brew install tmux
echo ""
echo "Installing zsh"
brew install zsh
echo ""
echo "Installing highlight"
brew install highlight
echo ""
echo "Installing nvm"
brew install nvm
echo ""
echo "Installing z"
brew install z
echo ""
echo "Installing markdown"
brew install markdown
echo ""
echo "Installation complete..."
echo ""

exit 0
