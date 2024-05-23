# Run the zsh.sh script from the scripts directory to set up Zsh environment
sh scripts/zsh.sh

# Create a .config directory in the user's home directory
mkdir ~/.config

# Remove existing .zshrc and .gitconfig files from the home directory
rm ~/.zshrc ~/.gitconfig

# Use stow to symlink the dotfiles from the repository to the appropriate locations
stow .

# Source the new .zshrc file to apply the Zsh configuration immediately
source ~/.zshrc
