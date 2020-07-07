#!/bin/sh

# development tools
echo ""
echo "Installing git"
brew install git
echo ""
echo "Install tmux"
brew install tmux
echo ""
echo "Installing iterm2"
brew cask install iterm2
echo ""
echo "Installing zsh"
brew install zsh
echo ""
echo "Installing Alfred"
brew cask install alfred
echo ""
echo "Installing Google Chrome"
brew cask install google-chrome
echo ""
echo "Installing Visual Studio Code"
brew cask install visual-studio-code
echo ""
echo "Installing 1Password"
brew cask install 1password
echo ""
echo "Installing Nord VPN"
brew cask install nordvpn
echo ""
echo "Installing Spotify"
brew cask install spotify
echo ""
echo "Installing slack"
brew cask install slack
echo ""
echo "Installing whatsapp"
brew cask install whatsapp
echo ""
echo "Installing oh-my-zsh"
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo ""
echo "Installation complete..."