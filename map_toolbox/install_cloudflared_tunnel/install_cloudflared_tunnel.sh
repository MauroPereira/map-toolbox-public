#!/bin/bash
set -e

# Instalación de Cloudflare Tunnel
echo "🛠️ Instalando cloudflared..."
curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -o /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared

# Autenticación
echo "🔐 Autenticando cloudflared..."
cloudflared tunnel login

# Creación de túnel
echo "🔧 Creando y configurando el túnel..."
TUNNEL_NAME="mi-tunel"
cloudflared tunnel create $TUNNEL_NAME
TUNNEL_ID=$(cloudflared tunnel list | grep $TUNNEL_NAME | awk '{print $1}')

# Configuración del túnel
echo "📝 Configurando cloudflared..."
mkdir -p /etc/cloudflared
cat <<EOF > /etc/cloudflared/config.yml
tunnel: $TUNNEL_ID
credentials-file: /root/.cloudflared/$TUNNEL_ID.json

ingress:
  - hostname: mi-dominio.com
    service: http://localhost:80
  - service: http_status:404
EOF

# Ejecutar el túnel como servicio
echo "🚀 Configurando servicio systemd..."
cat <<EOF > /etc/systemd/system/cloudflared.service
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared tunnel run $TUNNEL_NAME
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable cloudflared
echo "✅ Instalación completada. Ejecuta 'systemctl start cloudflared' para iniciar el túnel."
