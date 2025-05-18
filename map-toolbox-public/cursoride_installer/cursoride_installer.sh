#!/bin/bash

set -e  # Stop execution if an error occurs

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo "🔍 Script directory: $SCRIPT_DIR"

# Function to clean up on exit
cleanup() {
    if [ -f "$APPIMAGE_FILE" ]; then
        rm -f "$APPIMAGE_FILE"
    fi
}

# Set up trap for cleanup
trap cleanup EXIT

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Error: Please do not run this script as root"
    exit 1
fi

# Check if user has sudo privileges
if ! sudo -v &>/dev/null; then
    echo "❌ Error: User does not have sudo privileges"
    exit 1
fi

# Variables
APPIMAGE_FILE="/tmp/Cursor.AppImage"
INSTALL_PATH="/opt/cursor"
WRAPPER_PATH="/usr/bin/cursor"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"
DOWNLOAD_URL="https://downloads.cursor.com/production/8ea935e79a50a02da912a034bbeda84a6d3d355d/linux/x64/Cursor-0.50.4-x86_64.AppImage"

# Check for required dependencies
echo "🔍 Checking dependencies..."
if ! command -v wget &> /dev/null; then
    echo "❌ Error: wget is not installed"
    exit 1
fi

# Download Cursor
echo "📥 Downloading latest version of Cursor..."
if ! wget --https-only --secure-protocol=auto -O "$APPIMAGE_FILE" "$DOWNLOAD_URL"; then
    echo "❌ Error: Failed to download Cursor"
    echo "Please check your internet connection and try again"
    exit 1
fi

# Create installation directory if not exists
sudo mkdir -p "$INSTALL_PATH"

# Grant execution permissions and move to /opt
chmod +x "$APPIMAGE_FILE"
sudo mv "$APPIMAGE_FILE" "$INSTALL_PATH/Cursor.AppImage"

# Create wrapper script in /usr/bin
sudo bash -c "echo '#!/bin/bash' > $WRAPPER_PATH"
sudo bash -c "echo 'exec $INSTALL_PATH/Cursor.AppImage --no-sandbox \"\$@\" > /dev/null 2>&1 & disown' >> $WRAPPER_PATH"
sudo chmod +x "$WRAPPER_PATH"

# Install libfuse2 if necessary
if ! dpkg -s libfuse2 &> /dev/null; then
    echo "📦 Installing libfuse2..."
    sudo apt-get update
    sudo apt-get install -y libfuse2
fi

# Create a desktop shortcut for Ubuntu
echo "📝 Creating desktop shortcut..."
echo "[Desktop Entry]" | sudo tee "$DESKTOP_FILE" > /dev/null
echo "Name=Cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Exec=$WRAPPER_PATH" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Icon=$INSTALL_PATH/Cursor.AppImage" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Type=Application" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Categories=Development;" | sudo tee -a "$DESKTOP_FILE" > /dev/null

# Update desktop database
sudo update-desktop-database

echo "✅ Cursor successfully installed. You can run it with 'cursor .' in the terminal or from the Ubuntu menu."
