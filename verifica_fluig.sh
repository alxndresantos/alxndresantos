# Desenvolvido por Alexandre dos Santos (Coxa) - 26-08-2025
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
logfile="${LOG_DIR}/verifica_fluig.log"

server_url_file="/app/fluig/cloud.environment"
server_url_line=$(grep -E "^SERVER_URL=" "$server_url_file" 2>/dev/null)

IP_INTERNO=$(hostname -I | awk '{print $1}')
url_interna="http://${IP_INTERNO}:8080/health-check"

server_log="${LOG_DIR}/server.log"

########################################
# BLOCO 2 - FUNÇÕES
########################################

enviar_chat() {
    local mensagem="$1"
    curl -s -X POST \
        -H 'Content-Type: application/json' \
        -d "{\"text\": \"${mensagem}\"}" \
        "$WEBHOOK_URL" >/dev/null 2>&1
}

verifica_url() {
    curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$1"
}

reinicia_fluig() {
    msg="$(date '+%F %T') - Situação crítica detectada. Reiniciando serviços Fluig..."
    echo "$msg" | tee -a "$logfile"
    RESUMO+="$msg\n"
    PROBLEMA_ENCONTRADO=1

    systemctl stop nginx

    
    systemctl restart fluig
    sleep 10

    # Aguarda URL interna voltar
    tentativas_interna=0
    while [[ $tentativas_interna -lt 90 ]]; do
        status_interna=$(verifica_url "$url_interna")
        if [[ "$status_interna" -eq 200 ]]; then
            msg="$(date '+%F %T') - URL interna respondeu com 200 após $((tentativas_interna+1)) tentativas."
            echo "$msg" | tee -a "$logfile"
            RESUMO+="$msg\n"
            break
        fi
        sleep 15
        ((tentativas_interna++))
    done

    if [[ "$status_interna" -ne 200 ]]; then
        msg="$(date '+%F %T') - ERRO: URL interna não respondeu com 200 após 90 tentativas."
        echo "$msg" | tee -a "$logfile"
        RESUMO+="$msg\n"
        exit 1
    fi

    sleep 60
    systemctl start nginx

    # Aguarda URL externa voltar
    tentativas_externa=0
    while [[ $tentativas_externa -lt 30 ]]; do
        status_externa=$(verifica_url "$url_externa")
        if [[ "$status_externa" -eq 200 ]]; then
            msg="$(date '+%F %T') - URL externa respondeu com 200 após $((tentativas_externa+1)) tentativas. Serviços restaurados."
            echo "$msg" | tee -a "$logfile"
            RESUMO+="$msg\n"
            return
        fi
        sleep 10
        ((tentativas_externa++))
    done

    msg="$(date '+%F %T') - ERRO: URL externa não respondeu com 200 após 30 tentativas."
    echo "$msg" | tee -a "$logfile"
    RESUMO+="$msg\n"
    exit 1
}

########################################
# BLOCO 3 - EXECUÇÃO PRINCIPAL
########################################

if [[ -z "$server_url_line" ]]; then
    msg="$(date '+%F %T') - ERRO: Não foi possível encontrar SERVER_URL no arquivo $server_url_file."
    echo "$msg" | tee -a "$logfile"
    RESUMO+="$msg\n"
    PROBLEMA_ENCONTRADO=1
    enviar_chat "$RESUMO"
    exit 1
fi

url_externa="${server_url_line#SERVER_URL=}/services"

msg="$(date '+%F %T') - Início da verificação das URLs."
echo "$msg" | tee -a "$logfile"
RESUMO+="$msg\n"

status_interna=$(verifica_url "$url_interna")
msg="$(date '+%F %T') - Status URL interna ($url_interna): $status_interna"
echo "$msg" | tee -a "$logfile"
RESUMO+="$msg\n"
[[ "$status_interna" -ne 200 ]] && PROBLEMA_ENCONTRADO=1

status_externa=$(verifica_url "$url_externa")
if [[ "$status_externa" -eq 000 ]]; then
    msg="$(date '+%F %T') - ERRO: Falha na conexão com $url_externa"
    echo "$msg" | tee -a "$logfile"
    RESUMO+="$msg\n"
    PROBLEMA_ENCONTRADO=1
elif [[ "$status_externa" -eq 502 ]]; then
    msg="$(date '+%F %T') - ERRO: URL externa ($url_externa) retornou 502 (Bad Gateway)"
    echo "$msg" | tee -a "$logfile"
    RESUMO+="$msg\n"
    PROBLEMA_ENCONTRADO=1
else
    msg="$(date '+%F %T') - Status URL externa ($url_externa): $status_externa"
    echo "$msg" | tee -a "$logfile"
    RESUMO+="$msg\n"
    [[ "$status_externa" -ne 200 ]] && PROBLEMA_ENCONTRADO=1
fi

if [[ "$status_interna" -eq 200 && "$status_externa" -eq 200 ]]; then
    msg="$(date '+%F %T') - URLs interna e externa OK (200)."
    echo "$msg" | tee -a "$logfile"
    RESUMO+="$msg\n"

    if [[ -f "$server_log" ]]; then
        now_epoch=$(date +%s)
        found_travado=0
        linha_dataset=""

        while read -r line; do
            log_time=$(echo "$line" | awk '{print $1" "$2}' | sed 's/,/./')
            log_epoch=$(date -d "${log_time%.*}" +%s 2>/dev/null)
            if [[ -n "$log_epoch" ]]; then
                diff=$((now_epoch - log_epoch))
                segundos=$(echo "$line" | awk '{for(i=1;i<=NF;i++){if($i=="por"){print $(i+1);break}}}')
                if [[ $diff -le 900 && $segundos -gt 2000 ]]; then
                    found_travado=1
                    linha_dataset="$line"
                    break
                fi
            fi
        done < <(grep "ja esta sendo executado por" "$server_log" | grep -E "CustomizationManagerImpl.invokeFunction")

        if [[ $found_travado -eq 1 ]]; then
            msg="$(date '+%F %T') - Dataset travado detectado: $linha_dataset"
            echo "$msg" | tee -a "$logfile"
            RESUMO+="$msg\n"
            PROBLEMA_ENCONTRADO=1

            msg="$(date '+%F %T') - Reiniciando serviços devido a dataset travado."
            echo "$msg" | tee -a "$logfile"
            RESUMO+="$msg\n"
            reinicia_fluig
        else
            msg="$(date '+%F %T') - Nenhum dataset travado encontrado."
            echo "$msg" | tee -a "$logfile"
            RESUMO+="$msg\n"
        fi
    else
        msg="$(date '+%F %T') - Aviso: server.log não encontrado."
        echo "$msg" | tee -a "$logfile"
        RESUMO+="$msg\n"
    fi
else
    reinicia_fluig
fi

# Envia resumo final se houve problema
if [[ $PROBLEMA_ENCONTRADO -eq 1 ]]; then
    enviar_chat "$RESUMO"
fi
