#!/bin/bash

# Check if the script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Stop the Minecraft service
echo "Stopping the Minecraft service..."
systemctl stop Minecraft
echo "Minecraft service stopped."

# Check if a URL argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

# Get the URL from the command line argument
URL="$1"

# Use curl to download the file to a specific directory
DOWNLOAD_DIR="/tmp"
FILENAME=$(basename "$URL")
DOWNLOAD_PATH="$DOWNLOAD_DIR/$FILENAME"

# Use curl with a Chrome user agent
curl -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" -o "$DOWNLOAD_PATH" "$URL"

# Check if the downloaded file is a zip archive
if [[ "$FILENAME" == *.zip ]]; then
    # Create the 'newupdate' folder if it doesn't exist
    NEW_UPDATE_DIR="/home/tbryant/Desktop/Minecraft/newupdate"
    mkdir -p "$NEW_UPDATE_DIR"

    # Use unzip to extract the contents into 'newupdate'
    unzip -q "$DOWNLOAD_PATH" -d "$NEW_UPDATE_DIR"
    echo "File extracted: $FILENAME"

    # Remove specific files from the extracted folder
    rm -f "$NEW_UPDATE_DIR/allowlist.json" "$NEW_UPDATE_DIR/permissions.json" "$NEW_UPDATE_DIR/server.properties"

    # Copy files from the 'crimsonbedrock' directory to 'newupdate'
    CRIMSONBEDROCK_DIR="/home/tbryant/Desktop/Minecraft/crimsonbedrock"
    cp -r "$CRIMSONBEDROCK_DIR"/{allowlist.json,permissions.json,server.properties,worlds} "$NEW_UPDATE_DIR"
    echo "Files copied from crimsonbedrock to newupdate."

    # Rename folders
    mv "$CRIMSONBEDROCK_DIR" "$CRIMSONBEDROCK_DIR$RANDOM$RANDOM$RANDOM"
    mv "$NEW_UPDATE_DIR" "$CRIMSONBEDROCK_DIR"
    echo "Folders renamed."

    # Start the Minecraft service
    echo "Starting the Minecraft service..."
    systemctl start Minecraft
    echo "Minecraft service started."
else
    echo "The downloaded file is not a zip archive."
fi
