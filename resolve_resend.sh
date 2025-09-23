#!/bin/bash
CONF_FILE="/app/fluig/appserver/bin/domain.conf"
LINE='   JAVA_OPTS="$JAVA_OPTS -Dwcm.resend.batch.size=20"'

# Gera data/hora no formato YYYYMMDD_HHMMSS
BACKUP_FILE="${CONF_FILE}_$(date +%Y%m%d_%H%M%S)"

# Cria backup
echo "[INFO] Criando backup: $BACKUP_FILE"
cp "$CONF_FILE" "$BACKUP_FILE" || { echo "[ERRO] Falha ao criar backup."; exit 1; }

# Verifica se a linha já existe
if grep -qF "$LINE" "$CONF_FILE"; then
    echo "[INFO] A linha já existe em $CONF_FILE. Nenhuma alteração necessária."
else
    echo "[INFO] Inserindo configuração no $CONF_FILE..."
    sed -i '/-Djava.awt.headless=true/a\'"$LINE" "$CONF_FILE"
    echo "[INFO] Linha adicionada com sucesso!"
fi
