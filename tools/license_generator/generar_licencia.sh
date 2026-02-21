#!/bin/bash

# NOVA-ADEN - Generador de Licencias para el Desarrollador
# USO: ./generar_licencia.sh

echo "========================================"
echo "   NOVA-ADEN - Generador de Licencias"
echo "========================================"
echo ""

# Datos del cliente
read -p "ID Cliente (ej: CLIENTE001): " CLIENT_ID
read -p "Nombre del Negocio: " BUSINESS_NAME
read -p "Email/Teléfono: " CONTACT

# Generar hash único
TIMESTAMP=$(date +%s%N)
HASH_INPUT="${CLIENT_ID}-${BUSINESS_NAME}-${CONTACT}-${TIMESTAMP}"
HASH=$(echo -n "$HASH_INPUT" | sha256sum | cut -d' ' -f1 | tr '[:lower:]' '[:upper:]')

# Formatear como licencia NOVA-XXXX-XXXX-XXXX
LICENSE="NOVA-${HASH:0:4}-${HASH:4:4}-${HASH:8:4}"

echo ""
echo "========================================"
echo "✅ LICENCIA GENERADA"
echo "========================================"
echo "📋 Código: $LICENSE"
echo "👤 Cliente: $CLIENT_ID"
echo "🏢 Negocio: $BUSINESS_NAME"
echo "📅 Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"

# Guardar en registro
echo "$CLIENT_ID,$BUSINESS_NAME,$CONTACT,$LICENSE,$(date '+%Y-%m-%d'),Activo," >> clientes_registrados.csv

echo ""
echo "💡 Cliente registrado en: clientes_registrados.csv"
echo ""
echo "📱 Instrucciones para el cliente:"
echo "1. Instalar APK de nova-ADEN"
echo "2. Abrir aplicación"
echo "3. Ingresar código: $LICENSE"
echo "4. Presionar 'ACTIVAR LICENCIA'"
echo ""
