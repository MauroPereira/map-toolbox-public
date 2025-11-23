#!/bin/bash

set -e  # Stop execution if an error occurs

# Variables
DEB_FILE="/tmp/cursor.deb"

# Function to clean up on exit
cleanup() {
    echo "🧹 Cleaning up..."
    rm -f "$DEB_FILE"
}

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo "🔍 Script directory: $SCRIPT_DIR"

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
DEB_FILE="/tmp/cursor.deb"
INSTALL_PATH="/opt/cursor"
WRAPPER_PATH="/usr/bin/cursor"
DESKTOP_FILE="/usr/share/applications/cursor.desktop"

# Read DOWNLOAD_URL from file
if [ -f "$SCRIPT_DIR/url_link.txt" ]; then
    DOWNLOAD_URL=$(cat "$SCRIPT_DIR/url_link.txt" | tr -d '\n\r')
    echo "📋 Using URL from url_link.txt: $DOWNLOAD_URL"
else
    echo "❌ Error: url_link.txt file not found"
    echo "Please create a url_link.txt file with the Cursor download URL"
    exit 1
fi

# Validate URL format
if [[ ! "$DOWNLOAD_URL" =~ ^https?://.* ]]; then
    echo "❌ Error: Invalid URL format in url_link.txt"
    echo "URL must start with http:// or https://"
    exit 1
fi

# Check for required dependencies
echo "🔍 Checking dependencies..."
if ! command -v wget &> /dev/null; then
    echo "❌ Error: wget is not installed"
    exit 1
fi

if ! command -v dpkg &> /dev/null; then
    echo "❌ Error: dpkg is not installed. This script is for Debian-based systems."
    exit 1
fi


# Download Cursor
echo "📥 Downloading latest version of Cursor..."
if ! wget --https-only --secure-protocol=auto -O "$DEB_FILE" "$DOWNLOAD_URL"; then
    echo "❌ Error: Failed to download Cursor"
    echo "Please check your internet connection and try again"
    exit 1
fi

# Install the downloaded .deb file
echo "📦 Installing Cursor..."
sudo dpkg -i "$DEB_FILE"

# Fix any missing dependencies
echo "🔧 Fixing dependencies..."
sudo apt-get install -f -y

# The .deb package should handle the creation of desktop files and icons.
# If not, the old logic can be re-added here.

echo "✅ Cursor successfully installed. You can run it from the terminal or the applications menu."