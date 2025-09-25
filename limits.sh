#!/bin/bash
set -euo pipefail

LIMITS_FILE="/etc/security/limits.conf"

# Backup antes de alterar
cp -v "$LIMITS_FILE" "$LIMITS_FILE.bak.$(date +%F_%H-%M-%S)"

echo "[INFO] Ajustando limites para o usuário fluig em $LIMITS_FILE..."

# Adiciona entradas se ainda não existirem
grep -q "^fluig soft nproc" "$LIMITS_FILE" || echo "fluig soft nproc 65000" >> "$LIMITS_FILE"
grep -q "^fluig hard nproc" "$LIMITS_FILE" || echo "fluig hard nproc 65000" >> "$LIMITS_FILE"
grep -q "^fluig soft nofile" "$LIMITS_FILE" || echo "fluig soft nofile 65000" >> "$LIMITS_FILE"
grep -q "^fluig hard nofile" "$LIMITS_FILE" || echo "fluig hard nofile 65000" >> "$LIMITS_FILE"

echo "[INFO] Recarregando systemd..."
sudo systemctl daemon-reexec

echo "[INFO] Reiniciando serviço fluig_indexer..."
sudo systemctl stop fluig_indexer || true
sudo systemctl start fluig_indexer

echo "[OK] Ajuste concluído com sucesso!"
