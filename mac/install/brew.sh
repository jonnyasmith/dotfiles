#!/bin/sh

if ! command -v brew &> /dev/null
then
    printf "brew could not be found\n"
    exit
fi

taps=(
    azure-cli
    fzf
    jq
    neovim
    nvm
    starship
    tree
    tree-sitter
    zoxide
    olets/tap/zsh-abbr
)

for tap in "${taps[@]}"; do
    if ! brew list --formula | grep -q "^${tap}$"; then
        printf "Installing %s\n" "$tap"
        brew install "$tap"
    else
        printf "%s is already installed\n" "$tap"
    fi
done

if ! brew tap | grep -q "homebrew/cask-fonts"; then
  brew tap homebrew/cask-fonts
else
  echo "homebrew/cask-fonts tap is already installed"
fi

apps=(
    alfred
    docker
    font-fira-mono-nerd-font
    google-chrome
    grammarly
    iterm2
    jetbrains-toolbox
    karabiner-elements
    microsoft-edge
    microsoft-teams
    miro
    nordvpn
    parallels
    postman
    rectangle
    todoist
    visual-studio-code
)

for app in "${apps[@]}"; do
    if ! brew list --cask | grep -q "^${app}$"; then
        printf "Installing %s\n" "$app"
        brew install --cask "$app"
    else
        printf "%s is already installed\n" "$app"
    fi
done
