#!/bin/bash

# Check if apt is installed
if ! command -v app &> /dev/null
then
    printf "apt could not be found\n"
    exit
fi

# Update the package list and upgrade installed packages
echo "Updating packages..."
apt update
apt upgrade -y
