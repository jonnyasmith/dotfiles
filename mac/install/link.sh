#!/bin/bash

DOTFILES=$HOME/.dotfiles

printf "Creating symlinks\n"
linkables=$( find -H "$DOTFILES" -maxdepth 3 -name '*.symlink' )
for file in $linkables ; do
    target="$HOME/.$( basename $file ".symlink" )"
    if [ -e "$target" ]; then
        printf "Symlink $target already exists, deleting\n"
        rm $target
        printf "Creating symlink for $file\n"
        ln -s $file $target
    else
        printf "Creating symlink for $file\n"
        ln -s $file $target
    fi
done

if [ ! -d ~/.config ]; then
  printf "Creating symlink for ~/.config\n"
  ln -s $DOTFILES/config ~/.config
fi
