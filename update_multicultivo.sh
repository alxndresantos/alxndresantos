#!/bin/bash

# === CONFIGURAÇÕES ===
SERVICE_SCRIPT="/volume/TOTVSAgro/totvs_agro_multicultivo/wildfly/bin/wildfly-init-standalone.sh"
STANDALONE_DIR="/volume/TOTVSAgro/totvs_agro_multicultivo/wildfly/standalone"
ATT_DIR="/volume/att"
ZIP_FILE="$ATT_DIR/installer.zip"

# === CORES PARA LOG ===
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# === FUNÇÃO DE LOG ===
log() { echo -e "${BLUE}[INFO]${RESET} $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# === VALIDAR ARGUMENTO ===
if [ -z "$1" ]; then
    error "Você precisa informar a URL do instalador!"
    echo "Uso: $0 <ZIP_URL>"
    exit 1
fi
ZIP_URL="$1"

# === PARANDO O SERVIÇO ===
log "Parando o serviço..."
bash "$SERVICE_SCRIPT" stop || { error "Falha ao parar o serviço"; exit 1; }

# === REMOVENDO DIRETÓRIOS ===
log "Limpando data, log e tmp..."
rm -rf "$STANDALONE_DIR/data" "$STANDALONE_DIR/log" "$STANDALONE_DIR/tmp"

# === CRIANDO DIRETÓRIO ATT ===
mkdir -p "$ATT_DIR"

# === DOWNLOAD DO INSTALADOR ===
if [ -f "$ZIP_FILE" ]; then
    warn "Um instalador já existe em $ZIP_FILE. Removendo antes de baixar novamente."
    rm -f "$ZIP_FILE"
fi

while true; do
    log "Baixando instalador..."
    curl --fail --max-time 600 -L "$ZIP_URL" -o "$ZIP_FILE"
    if [ $? -eq 0 ]; then
        log "Download finalizado com sucesso!"
        break
    else
        warn "Falha no download. Tentando novamente em 10s..."
        sleep 10
    fi
done

# === DESCOMPACTANDO INSTALADOR ===
log "Descompactando instalador..."
unzip -o "$ZIP_FILE" -d "$ATT_DIR" || { error "Erro ao descompactar."; exit 1; }

# === EXECUTANDO INSTALADOR ===
cd "$ATT_DIR" || { error "Diretório $ATT_DIR não encontrado."; exit 1; }
chmod +x install.sh

log "Executando instalador..."
./install.sh
if [ $? -eq 0 ]; then
    log "Instalador finalizado com sucesso!"
else
    error "Erro durante a execução do instalador."
    exit 1
fi

# === REINICIANDO SERVIÇO ===
log "Iniciando o serviço novamente..."
bash "$SERVICE_SCRIPT" start || { error "Falha ao iniciar o serviço"; exit 1; }

echo -e "${GREEN}=== Processo concluído com sucesso! ===${RESET}"
