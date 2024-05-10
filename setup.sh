#!/bin/bash

# Check if the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Check if the files exist
if [ ! -f "crt" ] || [ ! -f "shaista_sub" ]; then
    echo "Error: Files 'crt' and 'shaista_sub' not found."
    exit 1
fi

# Move files to /usr/local/bin
mv crt shaista_sub /usr/local/bin/

echo "Files moved successfully to /usr/local/bin."
