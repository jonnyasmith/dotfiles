#!/bin/bash
set -e

# Enforce that all updates are installed before we begin
function check_macos_updated() {
	echo "Checking if macOS is up to date..."
	if [[ "$(sudo softwareupdate -l 2>&1)" != *"No new software available"* ]]; then
		echo "Updating macOS"
		sudo softwareupdate -i -a
		echo "Reboot your machine now and run this script again afterwards."
		exit 0
	else
		echo "This macOS is up to date."
	fi
}

# Install brew and XCode Command Line Tools
function install_brew() {
	if ! command -v brew >/dev/null 2>&1; then
		echo "Installing Brew..."
		printf "\n\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		brew analytics off
	else
		echo "Brew already installed."
	fi

	# NVM
        if [ ! -d ~/.nvm ]; then
		echo 'Installing NVM...'
		curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
        fi
}

function set_defaults() {
	echo "Setting user defaults"

    # echo "Finder: show all filename extensions"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # echo "show hidden files by default"
    defaults write com.apple.Finder AppleShowAllFiles -bool false

    # echo "only use UTF-8 in Terminal.app"
    defaults write com.apple.terminal StringEncodings -array 4

    echo "Automatically hide and show the Dock"
    defaults write com.apple.dock autohide -bool true

    echo "Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons"
    defaults write com.apple.finder QuitMenuItem -bool true

    echo "Use current directory as default search scope in Finder"
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # echo "Show Path bar in Finder"
    # defaults write com.apple.finder ShowPathbar -bool true

    echo "Show Status bar in Finder"
    defaults write com.apple.finder ShowStatusBar -bool true

    echo "Disable the warning when changing a file extension"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    echo "Disable the warning before emptying the Trash"
    defaults write com.apple.finder WarnOnEmptyTrash -bool false

    Empty Trash securely by default
    defaults write com.apple.finder EmptyTrashSecurely -bool true

    echo "Enable tap to click (Trackpad)"
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    echo "Enable Safari’s debug menu"
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

    echo "Restarting system apps"
    killall Finder
    Killall Dock
}

check_macos_updated;
install_brew;
set_defaults;