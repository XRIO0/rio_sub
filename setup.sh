#!/bin/bash

# Check if the files exist
if [ -f "crt" ] && [ -f "shaista_sub" ]; then
    # Set executable permissions on the files
    chmod +x crt shaista_sub
    # Move the files to /usr/local/bin
    sudo mv crt shaista_sub /usr/local/bin/
    echo "Files moved successfully."
else
    echo "Error: One or both files not found."
fi
