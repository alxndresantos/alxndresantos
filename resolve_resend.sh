#!/bin/bash
CONF_FILE="/app/fluig/appserver/bin/domain.conf"
LINE='   JAVA_OPTS="$JAVA_OPTS -Dwcm.resend.batch.size=20"'

# Verifica se a linha já existe
if grep -qF "$LINE" "$CONF_FILE"; then
    echo "[INFO] A linha já existe em $CONF_FILE. Nenhuma alteração necessária."
else
    echo "[INFO] Inserindo configuração no $CONF_FILE..."
    sed -i '/-Djava.awt.headless=true/a\'"$LINE" "$CONF_FILE"
    echo "[INFO] Linha adicionada com sucesso!"
fi
