#!/usr/bin/env bash
set -e

echo "🍺 Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH for this script
BREW_PREFIX="/home/linuxbrew/.linuxbrew"
export PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"

# Add to shell profile for future sessions
PROFILE_FILE=""
if [[ -f "$HOME/.bashrc" ]]; then
    PROFILE_FILE="$HOME/.bashrc"
elif [[ -f "$HOME/.zshrc" ]]; then
    PROFILE_FILE="$HOME/.zshrc"
fi

if [[ -n "$PROFILE_FILE" ]]; then
    grep -qxF 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' "$PROFILE_FILE" || echo 'export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"' >> "$PROFILE_FILE"
    grep -qxF 'export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"' "$PROFILE_FILE" || echo 'export PATH="/home/linuxbrew/.linuxbrew/sbin:$PATH"' >> "$PROFILE_FILE"
    echo "✅ Added Homebrew to $PROFILE_FILE"
fi

echo "🔍 Checking Homebrew version..."
brew --version

echo "📦 Installing gemini-cli..."
brew install gemini-cli

echo "📍 Gemini binary path:"
GEMINI_PATH=$(brew --prefix gemini-cli)/bin/gemini
if [[ ! -f "$GEMINI_PATH" ]]; then
    echo "❌ Error: gemini-cli binary not found at $GEMINI_PATH"
    exit 1
fi
echo "📍 Found gemini-cli at: $GEMINI_PATH"

echo "🔗 Creating symlink..."
sudo ln -sf "$GEMINI_PATH" /usr/local/bin/gemini-cli

echo "✅ Installation complete! gemini-cli version: $(gemini-cli --version)"

