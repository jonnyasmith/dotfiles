#!/bin/bash

# Check if apt is installed
if ! which apt &> /dev/null
then
    printf "apt could not be found\n"
    exit
fi

# Update the package list and upgrade installed packages
echo "Updating packages..."
apt update
apt upgrade -y


# List of packages to install (add or remove packages as needed)
packages_to_install=(
  code
  dbus-x11
  gnome-shell-extensions
  gnome-tweaks
  htop
  ubuntu-restricted-extras
  vlc
)

# Install packages
for package in "${packages_to_install[@]}"; do
  if dpkg -l | grep -q $package; then
    echo "$package is already installed."
  else
    apt install -y $package
  fi
done
