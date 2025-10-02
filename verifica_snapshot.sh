#!/bin/bash
# Rafael Noceli - 22/08/2025
#
# cleanup_snapshots.sh - Remove snapshots NFS inválidos (Stale file handle)
# Uso: pode ser agendado no cron em qualquer servidor que monte snapshots NetApp
#

LOGFILE="/var/log/cleanup_snapshots.log"
DATE=$(date +"%Y-%m-%d %H:%M:%S")

echo "[$DATE] Iniciando limpeza de snapshots inválidos..." >> "$LOGFILE"

# Lista os pontos de montagem em /volume/.snapshot
for SNAP in $(mount | awk '/\/volume\/\.snapshot/ {print $3}'); do
    # Testa se o snapshot ainda responde
    if ! df -h "$SNAP" &>/dev/null; then
        echo "[$DATE] Snapshot inválido detectado: $SNAP" >> "$LOGFILE"

        # Tenta desmontar com -f
        umount -f "$SNAP" 2>>"$LOGFILE"
        if mountpoint -q "$SNAP"; then
            echo "[$DATE] Forçando lazy umount em $SNAP" >> "$LOGFILE"
            umount -l "$SNAP" 2>>"$LOGFILE"
        fi

        # Se desmontou, remove o diretório
        if ! mountpoint -q "$SNAP"; then
            rmdir "$SNAP" 2>>"$LOGFILE" || rm -rf "$SNAP" 2>>"$LOGFILE"
            echo "[$DATE] Diretório removido: $SNAP" >> "$LOGFILE"
        fi
    fi
done

echo "[$DATE] Limpeza concluída." >> "$LOGFILE"
