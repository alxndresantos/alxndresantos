#!/bin/bash

# Caminhos
WILDFLY_SCRIPT="/volume/TOTVSAgro/totvs_agro_multicultivo/wildfly/bin/wildfly-init-standalone.sh"
LOCK_DIR="/var/lock/subsys"

# Função para log com timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Verificando status do WildFly..."

# Verifica o status
STATUS_OUTPUT=$("$WILDFLY_SCRIPT" status 2>&1)

if echo "$STATUS_OUTPUT" | grep -qi "stopped"; then
    log "WildFly está parado. Tentando iniciar..."
    "$WILDFLY_SCRIPT" start
elif echo "$STATUS_OUTPUT" | grep -qi "dead but subsys locked"; then
    log "WildFly travado com subsys lock. Limpando..."
    rm -rf "$LOCK_DIR"
    log "Iniciando o serviço após limpeza do lock..."
    sh "$WILDFLY_SCRIPT" start
else
    log "WildFly está em execução. Nenhuma ação necessária."
    exit 0
fi

# Valida se subiu com sucesso
sleep 5
NEW_STATUS=$("$WILDFLY_SCRIPT" status 2>&1)
if echo "$NEW_STATUS" | grep -qi "running"; then
    log "WildFly iniciado com sucesso."
else
    log "Falha ao iniciar o WildFly. Verifique manualmente."
fi
