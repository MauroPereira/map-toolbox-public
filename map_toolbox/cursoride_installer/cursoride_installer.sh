#!/bin/bash

set -e  # Detener ejecución si hay un error

# Variables
URL="https://download.cursor.sh/latest-linux"
DEB_FILE="cursor.deb"

# Descargar Cursor
wget -O "$DEB_FILE" "$URL"

# Instalar Cursor
dpkg -i "$DEB_FILE" || true  # Si hay errores de dependencias, continuamos
apt-get install -f -y  # Resolver dependencias

# Limpiar
rm "$DEB_FILE"

echo "✅ Cursor instalado correctamente. Puedes ejecutarlo con 'cursor'"
