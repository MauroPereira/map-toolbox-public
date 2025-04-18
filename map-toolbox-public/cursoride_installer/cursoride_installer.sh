#!/bin/bash

set -e  # Stop execution if an error occurs

# Variables
URL="https://downloads.cursor.com/production/1d623c4cc1d3bb6e0fe4f1d5434b47b958b05876/linux/x64/Cursor-0.48.7-x86_64.AppImage"
APPIMAGE_FILE="/tmp/Cursor.AppImage"
INSTALL_PATH="/opt/cursor"
WRAPPER_PATH="/usr/bin/cursor"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"

# Download Cursor
wget --https-only --secure-protocol=auto -O "$APPIMAGE_FILE" "$URL"

# Create installation directory if not exists
sudo mkdir -p "$INSTALL_PATH"

# Grant execution permissions and move to /opt
chmod +x "$APPIMAGE_FILE"
sudo mv "$APPIMAGE_FILE" "$INSTALL_PATH/Cursor.AppImage"

# Create wrapper script in /usr/bin
sudo bash -c "echo '#!/bin/bash' > $WRAPPER_PATH"
sudo bash -c "echo 'exec $INSTALL_PATH/Cursor.AppImage --no-sandbox "\$@" > /dev/null 2>&1 & disown' >> $WRAPPER_PATH"
sudo chmod +x "$WRAPPER_PATH"

# Install libfuse2 if necessary
if ! dpkg -s libfuse2 &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y libfuse2
fi

# Create a desktop shortcut for Ubuntu
echo "[Desktop Entry]" | sudo tee "$DESKTOP_FILE" > /dev/null
echo "Name=Cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Exec=$WRAPPER_PATH" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Icon=$INSTALL_PATH/Cursor.AppImage" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Type=Application" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Categories=Development;" | sudo tee -a "$DESKTOP_FILE" > /dev/null

# Update desktop database
sudo update-desktop-database

echo "✅ Cursor successfully installed. You can run it with 'cursor .' in the terminal or from the Ubuntu menu."
