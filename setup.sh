#!/bin/bash

# Check if the user has root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

# Define the destination directory
destination_dir="/usr/local/bin"

# Move the binary files to the destination directory
mv "crt" "$destination_dir/"
mv "shaista_sub" "$destination_dir/"

# Check if the move operation was successful
if [[ $? -eq 0 ]]; then
    echo "Binary files moved successfully to $destination_dir"
else
    echo "Error moving binary files"
fi
