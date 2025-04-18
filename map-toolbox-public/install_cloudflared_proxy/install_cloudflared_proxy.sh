#!/bin/bash

set -e

echo "Installing Cloudflare Tunnel (cloudflared) on Ubuntu 24.04..."

# Step 1: Add Cloudflare's GPG Key
echo "🔑 Adding Cloudflare's GPG Key..."
sudo mkdir -p --mode=0755 /etc/apt/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /etc/apt/keyrings/cloudflare-main.gpg >/dev/null

# Step 2: Add Cloudflare's Package Repository
echo "Adding Cloudflare's Repository..."
echo "deb [signed-by=/etc/apt/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflared.list

# Step 3: Install Cloudflared
echo "Installing Cloudflared..."
sudo apt update && sudo apt install -y cloudflared

# Step 4: Verify Installation
echo "Verifying Installation..."
cloudflared --version

echo "✅ Cloudflared installation completed!"
