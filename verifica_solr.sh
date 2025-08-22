#!/bin/bash

PORT=8983
LOGFILE="/var/log/fluig_indexer_monitor.log"

if ! nc -z localhost $PORT; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Porta $PORT inativa. Reiniciando fluig_indexer..." >> "$LOGFILE"
    systemctl start fluig_indexer
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Porta $PORT ativa. Nenhuma ação necessária." >> "$LOGFILE"
fi
