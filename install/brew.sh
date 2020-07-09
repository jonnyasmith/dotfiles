#!/bin/sh

taps=(
    git
    tmux
    zsh
)

brew install ${taps[@]}

apps=(
    1password
    alfred
    google-chrome
    iterm2
    microsoft-office
    microsoft-teams
    nordvpn
    parallels
    slack
    spectacle
    spotify
    visual-studio-code
    whatsapp
)

brew cask install --appdir="/Applications" ${apps[@]}