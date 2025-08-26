# Desenvolvido por Alexandre dos Santos (Coxa) - 09-08-2025
#!/bin/bash

########################################
# BLOCO 1 - VARIÁVEIS GLOBAIS
########################################

WEBHOOK_URL="https://chat.googleapis.com/v1/spaces/AAQAoeiHNcU/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=ApxNovCiJs6dKUcdDlbdmSfu9vqrGOH-Ft6J-G3GMqU"

HOSTNAME_ATUAL=$(hostname)

# Extrai cliente do hostname
CLIENTE_BASE=$(echo "$HOSTNAME_ATUAL" | grep -oP '(?<=-FL-P-)[^-]+')

# Extrai fantasy_name do JSON
FANTASY_NAME=$(jq -r '.customer.fantasy_name' /var/lib/cloud/instance/custom-data.json)

# Concatena cliente e fantasy_name
CLIENTE="${CLIENTE_BASE} - ${FANTASY_NAME}"

RESUMO="Resumo execução - $(date '+%F %T')\nCliente: $CLIENTE\nHostname: $HOSTNAME_ATUAL\n"
PROBLEMA_ENCONTRADO=0

LOG_DIR="/volume/logs/${HOSTNAME_ATUAL}"
mkdir -p "$LOG_DIR"
logfile="${LOG_DIR}/verifica_certificados.log"

# Arquivo com as URLs dos ambientes Fluig
server_url_file="/app/fluig/cloud.environment"


########################################
# BLOCO 2 - FUNÇÕES AUXILIARES
########################################

enviar_chat() {
    local mensagem="$1"
    curl -s -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"text\": \"${mensagem}\"}" \
        "$WEBHOOK_URL" >/dev/null 2>&1
}


########################################
# BLOCO 3 - VERIFICAÇÃO DOS CERTIFICADOS
########################################

verificar_certificados() {
    if [ ! -f "$server_url_file" ]; then
        echo "$(date '+%F %T') - Arquivo $server_url_file não encontrado" >> "$logfile"
        return 1
    fi

    # Pega todas as linhas SERVER_URL=
    grep -E "^SERVER_URL=" "$server_url_file" | while IFS= read -r line; do
        # Extrai a URL (ex.: SERVER_URL="https://fluig.dominio.com")
        server_url=$(echo "$line" | cut -d'=' -f2 | tr -d '"')

        # Extrai apenas o host
        host=$(echo "$server_url" | sed -E 's#https?://([^:/]+).*#\1#')

        # Obtém validade do certificado
        validade=$(echo | openssl s_client -servername "$host" -connect "$host:443" 2>/dev/null \
            | openssl x509 -noout -enddate \
            | cut -d= -f2)

        if [ -z "$validade" ]; then
            echo "$(date '+%F %T') - Não foi possível obter a validade do certificado para $host" >> "$logfile"
            continue
        fi

        # Converte validade para timestamp
        validade_ts=$(date -d "$validade" +%s)
        hoje_ts=$(date +%s)
        dias_restantes=$(( (validade_ts - hoje_ts) / 86400 ))

        echo "$(date '+%F %T') - Certificado $host vence em $dias_restantes dias" >> "$logfile"

        # Avalia situação
        if [ "$dias_restantes" -le 0 ]; then
            dias_passados=$(( dias_restantes * -1 ))
            if [ "$dias_restantes" -eq 0 ]; then
                mensagem="🚨 Atenção!  
Certificado SSL do cliente *$CLIENTE* no host *$host* *vence hoje* (Hostname: $HOSTNAME_ATUAL).  
Data de expiração: $validade"
            else
                mensagem="🚨 Atenção!  
Certificado SSL do cliente *$CLIENTE* no host *$host* *venceu há ${dias_passados} dias* (Hostname: $HOSTNAME_ATUAL).  
Data de expiração: $validade"
            fi
            enviar_chat "$mensagem"
            PROBLEMA_ENCONTRADO=1
        elif [ "$dias_restantes" -le 30 ]; then
            mensagem="🚨 Atenção!  
Certificado SSL do cliente *$CLIENTE* no host *$host* vence em *$dias_restantes dias* (Hostname: $HOSTNAME_ATUAL).  
Data de expiração: $validade"
            enviar_chat "$mensagem"
            PROBLEMA_ENCONTRADO=1
        fi
    done
}


########################################
# BLOCO 4 - EXECUÇÃO
########################################

echo "$(date '+%F %T') - Início da verificação dos certificados" >> "$logfile"

verificar_certificados

if [ "$PROBLEMA_ENCONTRADO" -eq 0 ]; then
    echo "$(date '+%F %T') - Nenhum problema encontrado nos certificados" >> "$logfile"
fi

echo "$(date '+%F %T') - Fim da execução" >> "$logfile"
