#!/bin/bash
set -e

# Solicitar token
echo "🔑 Por favor, ingrese el token de Cloudflare:"
read -r TOKEN

if [ -z "$TOKEN" ]; then
    echo "❌ Error: El token es requerido"
    exit 1
fi

# Instalación de Cloudflared
echo "🛠️ Instalando cloudflared..."
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

echo "📦 Instalando el paquete .deb..."
sudo dpkg -i cloudflared.deb

echo "🔐 Instalando el servicio con el token proporcionado..."
sudo cloudflared service install "$TOKEN"

echo "✅ Instalación completada."
