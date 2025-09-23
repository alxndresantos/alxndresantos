#!/bin/bash
# Script para analisar /var/lib/cloud/instance/custom-data.json
# Desenvolvido por Alexandre dos Santos (Coxa) - 22-09-2025

JSON_FILE="/var/lib/cloud/instance/custom-data.json"
LOG_FILE="/tmp/install_script_fluig.log"

# Verifica se o arquivo existe
if [ ! -f "$JSON_FILE" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - ERRO: Arquivo $JSON_FILE não encontrado!" | tee -a "$LOG_FILE"
  exit 1
fi

# Pega a quantidade de itens em loadbalances
COUNT=$(jq '.loadbalances | length' "$JSON_FILE" 2>/dev/null)

if [ "$COUNT" -eq 0 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Loadbalances vazio ([]). Executando fluig_sust_only_instance.sh" | tee -a "$LOG_FILE"
  cd /tmp || exit 1
  curl -s -o fluig_sust_only_instance.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_only_instance.sh
  sh /tmp/fluig_sust_only_instance.sh
  rm -f /tmp/fluig_sust_only_instance.sh
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Loadbalances contém $COUNT objeto(s). Executando fluig_sust_multi_instances.sh" | tee -a "$LOG_FILE"
  cd /tmp || exit 1
  curl -s -o fluig_sust_multi_instances.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_multi_instances.sh
  sh /tmp/fluig_sust_multi_instances.sh
  rm -f /tmp/fluig_sust_multi_instances.sh
fi
