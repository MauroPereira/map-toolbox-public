#!/usr/bin/env bash

set -e

# Default Homebrew paths
BREW_PATH="$HOME/.linuxbrew/bin/brew"
BREW_PATH_ALT="/home/linuxbrew/.linuxbrew/bin/brew"

install_brew() {
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

get_brew_cmd() {
    if [ -x "$BREW_PATH" ]; then
        echo "$BREW_PATH"
    elif [ -x "$BREW_PATH_ALT" ]; then
        echo "$BREW_PATH_ALT"
    elif command -v brew >/dev/null 2>&1; then
        command -v brew
    else
        echo ""
    fi
}

# Check if Homebrew is installed
BREW_CMD=$(get_brew_cmd)

if [ -z "$BREW_CMD" ]; then
    install_brew
    BREW_CMD=$(get_brew_cmd)
fi

if [ -z "$BREW_CMD" ]; then
    echo "❌ Could not find Homebrew after installation."
    exit 1
fi

echo "✅ Using Homebrew at: $BREW_CMD"

# Check if Homebrew bin is in PATH
BREW_BIN_DIR=$(dirname "$BREW_CMD")
if ! echo "$PATH" | grep -q "$BREW_BIN_DIR"; then
    echo "⚠️  Warning: Homebrew bin ($BREW_BIN_DIR) is not in your PATH."
    echo "You can add it by running:"
    echo "export PATH=\"$BREW_BIN_DIR:\$PATH\""
    echo "Or add that line to your ~/.profile or ~/.bashrc"
fi

# Install gemini-cli
"$BREW_CMD" install gemini-cli

# Always try to show gemini-cli version after installation
echo "🔍 Checking gemini-cli installation..."
if command -v gemini-cli >/dev/null 2>&1; then
    GEMINI_EXEC=$(command -v gemini-cli)
    echo "✅ gemini-cli is ready to use: $GEMINI_EXEC"
    echo "📋 Version: $(gemini-cli --version)"
    echo "🚀 To run gemini-cli, use: gemini-cli"
    echo "📍 Full path: $GEMINI_EXEC"
else
    echo "❌ gemini-cli not found in PATH after installation."
    echo "🔍 Checking if it's available via brew..."
    
    # Try to find gemini-cli in brew list
    if "$BREW_CMD" list | grep -q "gemini-cli"; then
        echo "📦 gemini-cli is installed via brew but not in PATH."
        echo "🔄 Try running: brew link --overwrite gemini-cli"
        echo "📋 Version: $("$BREW_CMD" exec gemini-cli --version)"
        echo "🚀 To run gemini-cli, use: brew exec gemini-cli"
        echo "📍 Full path: $("$BREW_CMD" --prefix)/bin/gemini-cli"
    else
        echo "❌ gemini-cli is not installed. Installation failed."
        exit 1
    fi
fi
