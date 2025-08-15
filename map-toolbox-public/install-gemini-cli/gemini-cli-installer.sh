#!/usr/bin/env bash

set -e

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Check brew version
brew --version

# Install gemini-cli
brew install gemini-cli

# Create symlink
sudo ln -sf /home/linuxbrew/.linuxbrew/Cellar/gemini-cli/0.1.21/bin/gemini /usr/bin/gemini-cli

# Checking gemini-cli version
echo "gemini-cli version installed: $(gemini-cli --version)"