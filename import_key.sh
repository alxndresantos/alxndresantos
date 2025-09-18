#!/bin/bash
# Script para importar certificado no Java do Fluig
# Desenvolvido por Alexandre dos Santos (Coxa) - 15-09-2025

# Diretório fixo de importação
CERT_DIR="/volume/importcert"
CERT_FILE="$CERT_DIR/cert.pem"
LOG_FILE="$CERT_DIR/import_cert.log"
JDK_DIR="/app/fluig/jdk-64"
KEYSTORE="$JDK_DIR/lib/security/cacerts"
STOREPASS="changeit"

# Gerar alias único fluigXXX (usar timestamp como sufixo)
ALIAS="fluig$(date +%s)"

# Criar pasta se não existir
mkdir -p "$CERT_DIR"

# Redirecionar saída para log e tela
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Início do processo de importação de certificado ($(date '+%Y-%m-%d %H:%M:%S')) ==="

# 1. Verificar se já existe o cert.pem
if [ ! -f "$CERT_FILE" ]; then
    echo "[INFO] Arquivo cert.pem não encontrado. Procurando por .pfx..."
    PFX_FILE=$(find "$CERT_DIR" -maxdepth 1 -type f -name "*.pfx" | head -n 1)

    if [ -n "$PFX_FILE" ]; then
        echo "[INFO] Arquivo PFX encontrado: $PFX_FILE"
        echo "[INFO] Exportando para cert.pem..."
        openssl pkcs12 -in "$PFX_FILE" -nokeys -out "$CERT_FILE"
        if [ $? -ne 0 ]; then
            echo "[ERRO] Falha ao exportar o cert.pem a partir do PFX."
            exit 1
        fi
    else
        echo "[ERRO] Nenhum arquivo cert.pem ou .pfx encontrado em $CERT_DIR"
        exit 1
    fi
fi

# 2. Validar se o certificado não está vencido
echo "[INFO] Verificando validade do certificado..."
EXPIRATION=$(openssl x509 -in "$CERT_FILE" -noout -enddate | cut -d= -f2)
EXPIRATION_TS=$(date -d "$EXPIRATION" +%s)
NOW_TS=$(date +%s)

if [ $NOW_TS -ge $EXPIRATION_TS ]; then
    echo "[ERRO] O certificado $CERT_FILE está expirado (Validade: $EXPIRATION)."
    exit 1
else
    echo "[OK] Certificado válido até: $EXPIRATION"
fi

# 3. Validar se a cadeia está completa (mas não bloquear se falhar)
echo "[INFO] Verificando se a cadeia do certificado está completa..."
openssl verify -CAfile "$CERT_FILE" "$CERT_FILE" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[AVISO] A cadeia de certificados pode não estar completa no cert.pem."
    echo "        O certificado será importado mesmo assim."
else
    echo "[OK] Cadeia de certificados validada com sucesso."
fi

# 4. Importar no Java do Fluig
echo "[INFO] Importando certificado no Java com alias: $ALIAS"
cd "$JDK_DIR/lib/security" || exit 1
"$JDK_DIR/bin/keytool" -import -trustcacerts \
  -alias "$ALIAS" \
  -file "$CERT_FILE" \
  -keystore "$KEYSTORE" \
  -storepass "$STOREPASS" \
  -noprompt

if [ $? -eq 0 ]; then
    echo "[SUCESSO] Certificado importado com sucesso no keystore com alias: $ALIAS"
else
    echo "[ERRO] Falha na importação do certificado."
    exit 1
fi

echo "=== Processo finalizado ($(date '+%Y-%m-%d %H:%M:%S')) ==="
