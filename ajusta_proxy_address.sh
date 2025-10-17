#!/bin/bash
# ---------------------------------------------------------
# Script: ajusta_proxy_address.sh
# Objetivo: Garantir que a tag <http-listener> contenha o
# atributo proxy-address-forwarding="true" no domain.xml
# Autor: Alexandre dos Santos (Coxa)
# Data: $(date +%d-%m-%Y)
# ---------------------------------------------------------

FILE="/app/fluig/appserver/domain/configuration/domain.xml"

# Verifica se o arquivo existe
if [ ! -f "$FILE" ]; then
    echo "❌ Arquivo não encontrado: $FILE"
    exit 1
fi

# Cria backup com data e hora
BACKUP="${FILE}_$(date +%Y%m%d%H%M%S)"
cp "$FILE" "$BACKUP"
echo "🗂️  Backup criado: $BACKUP"

# Verifica se o atributo já existe
if grep -q 'proxy-address-forwarding=' "$FILE"; then
    echo "✅ O atributo proxy-address-forwarding já existe. Nenhuma alteração necessária."
else
    # Adiciona o atributo antes de socket-binding="http"
    sed -i 's/\(<http-listener[^>]*\)\(socket-binding="http"[^>]*>\)/\1 proxy-address-forwarding="true" \2/' "$FILE"
    
    if grep -q 'proxy-address-forwarding=' "$FILE"; then
        echo "✅ Atributo proxy-address-forwarding adicionado com sucesso."
    else
        echo "⚠️  Não foi possível adicionar o atributo. Verifique o formato da tag <http-listener>."
    fi
fi
