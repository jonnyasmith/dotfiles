#!/bin/bash

DOTFILES=$HOME/.dotfiles

printf "Creating symlinks\n"
linkables=$( find -H "$DOTFILES" -maxdepth 3 -name '*.symlink' )
for file in $linkables ; do
    target="$HOME/.$( basename $file ".symlink" )"
    if [ -e "$target" ]; then
        printf "Symlink $target already exists, skipping\n"
    else
        printf "Creating symlink for $file\n"
        ln -s $file $target
    fi
done

# loop through the list in $DOTFILES/config and create the symlinks in $HOME/.config
printf "\nCreating symlinks for .config\n"
config_files=$( find $DOTFILES/config -maxdepth 1 2>/dev/null )
for config in $config_files; do
    target="$HOME/.config/$( basename $config )"
    if [ -e "$target" ]; then
        printf "Symlink $target already exists, skipping\n"
    else
        printf "Creating symlink for $config\n"
        ln -s $config $target
    fi
done
