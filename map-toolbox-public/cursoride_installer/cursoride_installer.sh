#!/bin/bash

set -e  # Stop execution if an error occurs

# Parse command line arguments
ONLY_MENU_ACCESS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --only-menu-access)
            ONLY_MENU_ACCESS=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --only-menu-access    Only update icons and menu access, skip AppImage download and installation"
            echo "  -h, --help     Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0              # Full installation"
            echo "  $0 --only-menu-access  # Only update menu access"
            exit 0
            ;;
        *)
            echo "❌ Error: Unknown option $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo "🔍 Script directory: $SCRIPT_DIR"

# Function to clean up on exit
cleanup() {
    if [ -f "$APPIMAGE_FILE" ]; then
        rm -f "$APPIMAGE_FILE"
    fi
    rm -rf "$EXTRACT_DIR"
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
ICON_DEST="/usr/share/icons/hicolor/128x128/apps/cursor.png"
DOWNLOAD_URL="https://downloads.cursor.com/production/031e7e0ff1e2eda9c1a0f5df67d44053b059c5df/linux/x64/Cursor-1.2.1-x86_64.AppImage"
EXTRACT_DIR="/tmp/cursor_extracted"

# Check for required dependencies
echo "🔍 Checking dependencies..."
if ! command -v wget &> /dev/null; then
    echo "❌ Error: wget is not installed"
    exit 1
fi

# Function to install icons
install_icons() {
    echo "🎨 Installing icons..."
    
    # Get current user
    CURRENT_USER=$(whoami)
    
    # Define icon sizes to install
    ICON_SIZES=("16x16" "32x32" "48x48" "64x64" "128x128" "256x256" "512x512")
    
    # Check if we have the extracted AppImage
    if [ ! -d "$EXTRACT_DIR/squashfs-root" ]; then
        echo "❌ Error: AppImage not extracted. Cannot install icons."
        return 1
    fi
    
    # Install icons for each size
    for size in "${ICON_SIZES[@]}"; do
        icon_path="$EXTRACT_DIR/squashfs-root/usr/share/icons/hicolor/$size/apps/cursor.png"
        if [ -f "$icon_path" ]; then
            sudo mkdir -p "/usr/share/icons/hicolor/$size/apps/"
            sudo cp "$icon_path" "/usr/share/icons/hicolor/$size/apps/cursor.png"
            # Set ownership to current user and group
            sudo chown "$CURRENT_USER:$CURRENT_USER" "/usr/share/icons/hicolor/$size/apps/cursor.png"
            # Set permissions to allow user to delete
            sudo chmod 644 "/usr/share/icons/hicolor/$size/apps/cursor.png"
            echo "✅ Installed $size icon (owned by $CURRENT_USER)"
        else
            echo "⚠️ $size icon not found, skipping..."
        fi
    done
    
    # Update icon cache
    echo "🔄 Updating icon cache..."
    if command -v gtk-update-icon-cache &> /dev/null; then
        sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor
    fi
    
    # Update desktop database
    sudo update-desktop-database
    echo "✅ Icons installed successfully!"
}

# Function to update menu access only
update_menu_access() {
    echo "🎨 Updating menu access only..."
    
    # Check if Cursor is already installed
    if [ ! -f "$INSTALL_PATH/Cursor.AppImage" ]; then
        echo "❌ Error: Cursor is not installed. Please run the full installation first."
        exit 1
    fi
    
    # Extract AppImage to get the icon
    echo "📦 Extracting AppImage for icon..."
    mkdir -p "$EXTRACT_DIR"
    cd "$EXTRACT_DIR"
    "$INSTALL_PATH/Cursor.AppImage" --appimage-extract > /dev/null
    
    # Install icons
    install_icons
    
    # Create desktop file if it doesn't exist
    if [ ! -f "$DESKTOP_FILE" ]; then
        echo "📝 Creating desktop shortcut..."
        echo "[Desktop Entry]" | sudo tee "$DESKTOP_FILE" > /dev/null
        echo "Name=Cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
        echo "Comment=AI-first code editor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
        echo "Exec=$WRAPPER_PATH" | sudo tee -a "$DESKTOP_FILE" > /dev/null
        echo "Icon=cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
        echo "Type=Application" | sudo tee -a "$DESKTOP_FILE" > /dev/null
        echo "Categories=Development;IDE;TextEditor;" | sudo tee -a "$DESKTOP_FILE" > /dev/null
        echo "Keywords=cursor;code;editor;ai;programming;" | sudo tee -a "$DESKTOP_FILE" > /dev/null
        echo "StartupWMClass=Cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
        # Set ownership to current user
        sudo chown "$CURRENT_USER:$CURRENT_USER" "$DESKTOP_FILE"
        sudo chmod 644 "$DESKTOP_FILE"
        echo "✅ Desktop file created!"
    else
        echo "✅ Desktop file already exists"
    fi
    
    echo "✅ Menu access update completed!"
    exit 0
}

# If only menu access update is requested
if [ "$ONLY_MENU_ACCESS" = true ]; then
    update_menu_access
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

# Extract AppImage to get the icon
echo "📦 Extracting AppImage for icon..."
mkdir -p "$EXTRACT_DIR"
cd "$EXTRACT_DIR"
"$INSTALL_PATH/Cursor.AppImage" --appimage-extract > /dev/null

# Install icons
install_icons

# Create a desktop shortcut
echo "📝 Creating desktop shortcut..."
echo "[Desktop Entry]" | sudo tee "$DESKTOP_FILE" > /dev/null
echo "Name=Cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Comment=AI-first code editor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Exec=$WRAPPER_PATH" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Icon=cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Type=Application" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Categories=Development;IDE;TextEditor;" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "Keywords=cursor;code;editor;ai;programming;" | sudo tee -a "$DESKTOP_FILE" > /dev/null
echo "StartupWMClass=Cursor" | sudo tee -a "$DESKTOP_FILE" > /dev/null
# Set ownership to current user
sudo chown "$CURRENT_USER:$CURRENT_USER" "$DESKTOP_FILE"
sudo chmod 644 "$DESKTOP_FILE"

# Update desktop database
sudo update-desktop-database

echo "✅ Cursor successfully installed. You can run it with 'cursor .' in the terminal or from the Ubuntu menu."

