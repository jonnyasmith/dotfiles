# Run the zsh.sh script from the scripts directory to set up Zsh environment
sh ~/.dotfiles/scripts/zsh.sh

# Install the latest LTS version of Node.js
nvm install --lts

# Install Prettier globally using npm
npm install prettier -g

# Create a .config directory in the user's home directory
mkdir ~/.config

# Remove existing .zshrc and .gitconfig files from the home directory
rm ~/.zshrc ~/.gitconfig

# Use stow to symlink the dotfiles from the repository to the appropriate locations
stow .

# Source the new .zshrc file to apply the Zsh configuration immediately
source ~/.zshrc
