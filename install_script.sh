#!/bin/bash
# Script para analisar /var/lib/cloud/instance/custom-data.json
# Desenvolvido por Alexandre dos Santos (Coxa) - 20-09-2025

JSON_FILE="/var/lib/cloud/instance/custom-data.json"

# Verifica se o arquivo existe
if [ ! -f "$JSON_FILE" ]; then
  echo "Arquivo $JSON_FILE não encontrado!"
  exit 1
fi

# Pega somente a linha com "loadbalances"
LOADBALANCES=$(grep -o '"loadbalances":[^}]*' "$JSON_FILE" | sed 's/"loadbalances"://;s/[[:space:]]//g')

# Se loadbalances for []
if [[ "$LOADBALANCES" == "[]" ]]; then
  echo "Loadbalances vazio. Executando fluig_sust_std.sh..."
  cd /tmp || exit 1
  curl -s -o fluig_sust_std.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh
  sh /tmp/fluig_sust_std.sh
  rm -f /tmp/fluig_sust_std.sh

# Se loadbalances tiver objetos dentro
elif [[ "$LOADBALANCES" =~ ^\[.*\{.*\}.*\]$ ]]; then
  echo "Loadbalances preenchido ($LOADBALANCES). Executando fluig_sust.sh..."
  cd /tmp || exit 1
  curl -s -o fluig_sust.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh
  sh /tmp/fluig_sust.sh
  rm -f /tmp/fluig_sust.sh

else
  echo "Formato inesperado em loadbalances: $LOADBALANCES"
fi
