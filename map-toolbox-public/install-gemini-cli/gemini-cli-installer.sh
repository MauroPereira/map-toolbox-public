#!/usr/bin/env bash

set -e

# Install brew
echo "🍺 Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH for Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Adding Homebrew to PATH for Linux..."
    # Add Homebrew to PATH for current session
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"
    
    # Add to shell profile for future sessions
    if [[ -f "$HOME/.bashrc" ]]; then
        echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"' >> "$HOME/.bashrc"
        echo "✅ Added Homebrew to .bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> "$HOME/.zshrc"
        echo 'export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"' >> "$HOME/.zshrc"
        echo "✅ Added Homebrew to .zshrc"
    fi
    
    # Source the profile to make brew available immediately
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        source "$HOME/.zshrc"
    fi
fi

# Check brew version
echo "🔍 Checking Homebrew version..."
brew --version

# Install gemini-cli
echo "📦 Installing gemini-cli..."
brew install gemini-cli

# Find the actual installed path dynamically
echo "🔍 Finding gemini-cli installation path..."
GEMINI_PATH=$(find /home/linuxbrew/.linuxbrew/Cellar/gemini-cli -name "gemini" -type f 2>/dev/null | head -n 1)

if [ -z "$GEMINI_PATH" ]; then
    echo "❌ Error: Could not find gemini-cli binary"
    exit 1
fi

echo "📍 Found gemini-cli at: $GEMINI_PATH"

# Create symlink
echo "🔗 Creating symlink..."
sudo ln -sf "$GEMINI_PATH" /usr/bin/gemini-cli

# Verify the symlink was created
if [ -L "/usr/bin/gemini-cli" ]; then
    echo "✅ Symlink created successfully"
else
    echo "❌ Failed to create symlink"
    exit 1
fi

# Checking gemini-cli version
echo "✅ Installation complete! gemini-cli version: $(gemini-cli --version)"
echo "💡 You may need to restart your terminal or run 'source ~/.bashrc' for changes to take effect"