# Dotfiles

## Contents

+ zsh configuration
+ vim configuration
+ tmux configuration
+ git configuration
+ osx configuration
+ node.js setup (nvm)
+ homebrew files (brewfile.sh)

## Install

1. git clone https://github.com/jonnyasmith/dotfiles.git ~/.dotfiles
2. cd ~/.dotfiles
3. sh install.sh

## ZSH Plugins

BY default, the '.zshrc' file will source any file within '.dotfiles/zsh' what have the '.zsh' extension.

## Vim Plugins

Vim plugins are managed with [vim-plug](https://github.com/junegunn/vim-plug). To install, run 'vim +PlugInstall'


## Windows install

Reference for [Scoop](https://www.outcoldman.com/en/archive/2014/07/20/scoop/)

1. Open powershell
2. set-executionpolicy unrestricted -s cu
3. iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
4. scoop install 7zip coreutils curl git grep openssh sed wget vim grep
