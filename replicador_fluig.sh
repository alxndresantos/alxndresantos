#!/bin/bash

# Códigos de cor
VERDE="\e[32m"
RESET="\e[0m"

# Funções auxiliares
eh_sim() { [[ "$1" =~ ^([Yy]|[Yy][Ee][Ss]|[Ss]im|SIM|sim)$ ]]; }
eh_nao() { [[ "$1" =~ ^([Nn]|[Nn][Oo]|[Nn]ao|[Nn]ão|NAO|NÃO)$ ]]; }

# Pergunta inicial
read -p "Informe o nome do cliente (ex.: powersul): " CLIENTE
echo "Este servidor é ORIGEM (envia para o bucket) ou DESTINO (recebe do bucket)?"
read -p "Digite [origem/destino]: " TIPO_SERVIDOR

# Data/hora para logs
DATA=$(date +"%Y%m%d-%H%M%S")

# Diretórios locais
DIR_APPS="/volume/apps"
DIR_WCMDIR="/volume/wcmdir"
DIR_WDKDATA="/volume/wdk-data"
DIR_FORMS="/volume/wdk-data/forms"

# Criar logs
mkdir -p logs-bucket

if [[ "$TIPO_SERVIDOR" =~ ^([Oo]rigem|ORIGEM|origem)$ ]]; then
    ###############################
    # 🚀 MODO ORIGEM (envio p/ bucket)
    ###############################

    # Coleta credenciais AWS
    read -p "Informe o nome do bucket S3: " BUCKET
    read -p "Informe o Secret Access Key: " AWS_SECRET_ACCESS_KEY
    read -p "Informe a URL do endpoint (ex.: https://meu-endpoint:9007): " ENDPOINT

    # Configura o AWS CLI sem interação
    aws configure set aws_access_key_id "$BUCKET"
    aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
    aws configure set default.region us-east-1

    echo
    echo "=== Configuração da pasta wdk-data ==="
    read -p "Deseja que algum diretório dentro de wdk-data NÃO seja enviado? (sim/não): " RESPOSTA_EXCLUIR

    EXCLUDE_ARGS=()
    UPLOADS=()
    LOGS=()

    if eh_sim "$RESPOSTA_EXCLUIR"; then
        read -p "Qual diretório deseja excluir? (ex.: public): " DIR_EXCLUIR
        EXCLUDE_ARGS=(--exclude "$DIR_EXCLUIR/*")
        UPLOADS+=("$DIR_WDKDATA")
        LOGS+=("logs-bucket/log-wdkdata-$DATA.out")
    else
        read -p "Deseja enviar SOMENTE a pasta forms? (sim/não): " RESPOSTA_FORMS
        if eh_sim "$RESPOSTA_FORMS"; then
            UPLOADS+=("$DIR_FORMS")
            LOGS+=("logs-bucket/log-forms-$DATA.out")
        else
            UPLOADS+=("$DIR_WDKDATA")
            LOGS+=("logs-bucket/log-wdkdata-$DATA.out")
        fi
    fi

    # Adicionar apps e wcmdir
    UPLOADS+=("$DIR_APPS" "$DIR_WCMDIR")
    LOGS+=("logs-bucket/log-apps-$DATA.out" "logs-bucket/log-wcmdir-$DATA.out")

    # Função de upload com monitor (agora prefixa com CLIENTE)
    upload_monitor() {
        local DIR="$1"
        local LOG="$2"
        local DEST="s3://$BUCKET/$CLIENTE/$(basename $DIR)/"

        aws s3 sync "$DIR" "$DEST" "${EXCLUDE_ARGS[@]}" --endpoint-url "$ENDPOINT" > "$LOG" 2>&1 &
        PID=$!

        tput civis
        while kill -0 $PID 2>/dev/null; do
            printf "\r⏳ Enviando %-10s ..." "$(basename $DIR)"
            sleep 1
        done
        wait $PID
        printf "\r✅ %-10s enviado com sucesso!                        \n" "$(basename $DIR)"
        tput cnorm
    }

    # Imprime o cabeçalho uma única vez
    echo "🚀 MODO ORIGEM (envio p/ bucket)"
    for i in "${!UPLOADS[@]}"; do
        upload_monitor "${UPLOADS[$i]}" "${LOGS[$i]}" &
    done

    wait
    echo -e "${VERDE}✅ Todos os uploads foram concluídos!${RESET}"
    echo "📂 Veja os arquivos de log na pasta 'logs-bucket/'"

elif [[ "$TIPO_SERVIDOR" =~ ^([Dd]estino|DESTINO|destino)$ ]]; then
    ###############################
    # 📥 MODO DESTINO (recebe do bucket)
    ###############################

    echo "=== Configuração do servidor DESTINO ==="
    read -p "Informe a URL completa do bucket de origem: " ORIGEM_BUCKET
    read -p "Informe o diretório de destino local (ex.: /volume/wdk-data/): " DIR_LOCAL
    read -p "Informe a URL do endpoint (ex.: https://arizona-tera.totvscloud.com.br:9007): " ENDPOINT

    LOG_DESTINO="logs-bucket/log-destino-$DATA.out"
    echo "⏳ Iniciando download do bucket para $DIR_LOCAL ..."
    nohup aws s3 cp "$ORIGEM_BUCKET" "$DIR_LOCAL" --recursive --endpoint-url "$ENDPOINT" > "$LOG_DESTINO" 2>&1 &
    PID=$!

    tput civis
    echo "📥 MODO DESTINO (recebe do bucket)"
    while kill -0 $PID 2>/dev/null; do
        printf "\r⏳ Baixando arquivos ... "
        sleep 2
    done
    wait $PID
    tput cnorm

    echo -e "${VERDE}✅ Download concluído com sucesso!${RESET}"
    echo "📂 Veja os logs em: $LOG_DESTINO"

else
    echo "❌ Opção inválida! Digite 'origem' ou 'destino'."
    exit 1
fi
