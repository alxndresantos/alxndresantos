#!/bin/bash
# Script para analisar /var/lib/cloud/instance/custom-data.json
# Desenvolvido por Alexandre dos Santos (Coxa) - 21-09-2025

JSON_FILE="/var/lib/cloud/instance/custom-data.json"
LOG_FILE="/tmp/install_script_fluig.log"

# Verifica se o arquivo existe
if [ ! -f "$JSON_FILE" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERRO: Arquivo $JSON_FILE não encontrado!" | tee -a "$LOG_FILE"
  exit 1
fi

# Verifica se loadbalances contém "floating_ip"
if grep -q '"floating_ip"' "$JSON_FILE"; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Loadbalances preenchido. Executando fluig_sust.sh..." | tee -a "$LOG_FILE"
  cd /tmp || exit 1
  curl -s -o fluig_sust.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh
  sh /tmp/fluig_sust.sh
  rm -f /tmp/fluig_sust.sh
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Loadbalances vazio. Executando fluig_sust_std.sh..." | tee -a "$LOG_FILE"
  cd /tmp || exit 1
  curl -s -o fluig_sust_std.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh
  sh /tmp/fluig_sust_std.sh
  rm -f /tmp/fluig_sust_std.sh
fi
