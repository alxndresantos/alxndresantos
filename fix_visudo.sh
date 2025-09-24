#!/bin/bash
set -euo pipefail

# Backup antes de qualquer coisa
cp -v /etc/sudoers /etc/sudoers.bak.$(date +%F_%H-%M-%S)

echo "[INFO] Removendo linhas inválidas do /etc/sudoers..."
# Remove linhas que começam com echo ou tee
sed -i '/echo.*tee/d' /etc/sudoers

echo "[INFO] Criando regras corretas no /etc/sudoers.d/..."
# Cria arquivos específicos para os usuários
echo "cloud-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cloud-user
echo "gwusr ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gwusr

# Ajusta permissões corretas
chmod 440 /etc/sudoers.d/cloud-user
chmod 440 /etc/sudoers.d/gwusr

echo "[INFO] Adicionando regras diretamente no final do /etc/sudoers..."
RULES="cloud-user ALL=(ALL) NOPASSWD:ALL
gwusr ALL=(ALL) NOPASSWD:ALL"
echo "$RULES" | EDITOR="tee -a" visudo

echo "[INFO] Validando sudoers..."
if visudo -c; then
    echo "[OK] sudoers corrigido e linhas adicionadas com sucesso!"
else
    echo "[ERRO] Ainda há problema no sudoers. Restaurando backup..."
    cp -v /etc/sudoers.bak.* /etc/sudoers
    exit 1
fi
