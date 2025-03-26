#!/bin/bash

set -e  # Stop execution if an error occurs

# Variables
URL="https://downloads.cursor.com/production/b6fb41b5f36bda05cab7109606e7404a65d1ff32/linux/x64/Cursor-0.47.9-x86_64.AppImage"
APPIMAGE_FILE="/tmp/Cursor.AppImage"
INSTALL_PATH="/usr/bin/cursor"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"

# Download Cursor
wget --https-only --secure-protocol=auto -O "$APPIMAGE_FILE" "$URL"

# Grant execution permissions and move to /usr/bin
chmod +x "$APPIMAGE_FILE"
sudo mv "$APPIMAGE_FILE" "$INSTALL_PATH"

# Install libfuse2 if necessary
if ! dpkg -s libfuse2 &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y libfuse2
fi

# Create a desktop shortcut for Ubuntu
echo "[Desktop Entry]" | sudo tee "$DESKTOP_FILE" > /dev/null
echo "Name=Cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Exec=$INSTALL_PATH --no-sandbox" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Icon=$INSTALL_PATH" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Type=Application" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Categories=Development;" | sudo tee -a "$DESKTOP_FILE" > /dev/null

# Update desktop database
sudo update-desktop-database

echo "✅ Cursor successfully installed. You can run it with 'cursor .' in the terminal or from the Ubuntu menu."
