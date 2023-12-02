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
    lazygit
    neovim
    nvm
    starship
    terraform
    tmux
    tree
    tree-sitter
    zoxide
    zsh
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

apps=(
    1password
    alfred
    docker
    google-chrome
    grammarly
    iterm2
    jetbrains-toolbox
    karabiner-elements
    microsoft-office
    microsoft-teams
    miro
    nordvpn
    parallels
    postman
    powershell
    rectangle
    spectacle
    todoist
    transmission
    visual-studio-code
    whatsapp
)

for app in "${apps[@]}"; do
    if ! brew list --cask | grep -q "^${app}$"; then
        printf "Installing %s\n" "$app"
        brew install --cask "$app"
    else
        printf "%s is already installed\n" "$app"
    fi
done
