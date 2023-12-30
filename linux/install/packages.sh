#!/bin/bash

# List of packages to install (add or remove packages as needed)
packages_to_install=(
  dbus-x11
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

snap refresh

# List of Snap packages to install (add or remove packages as needed)
snap_packages_to_install=(
  code
)

# Install Snap packages
for package in "${snap_packages_to_install[@]}"; do
  if snap list | grep -q $package; then
    echo "$package is already installed."
  else
    snap install --classic $package
  fi
done
