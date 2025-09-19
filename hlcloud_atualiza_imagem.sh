#!/bin/bash
set -euo pipefail

# Arquivo com credenciais
CRED_FILE="/totvs/script/az_credentials"
if [[ -f "$CRED_FILE" ]]; then
  source "$CRED_FILE"
else
  echo "Erro: arquivo $CRED_FILE não encontrado!"
  exit 1
fi

SERVER_LIST="/totvs/script/serverlist.txt"
SSH_KEY="$HOME/.ssh/id_rsa_swarm"
SSH_OPTIONS="-o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=10"

TAG="$1"

IMAGES=(
  "hlcloud.azurecr.io/hlcloud/smartclient-server-erp:1.0.1-$TAG"
  "hlcloud.azurecr.io/hlcloud/smartclient-html-erp:1.0.1-$TAG"
  "hlcloud.azurecr.io/hlcloud/rest-server:1.0.1-$TAG"
  "hlcloud.azurecr.io/hlcloud/base-appserver:1.0.1-$TAG"
  "hlcloud.azurecr.io/hlcloud/webservice-server:1.0.1-$TAG"
  "hlcloud.azurecr.io/hlcloud/schedule-manager:1.0.1-$TAG"
)

SERVICES=(
  "hlcloud_erp-compilacao"
  "hlcloud_erp-sc-html"
  "hlcloud_rpc-agent-01"
  "hlcloud_sch-agent-01"
  "hlcloud_schedule-manager"
  "hlcloud_restservice"
  "hlcloud_webservice"
  "hlcloud_erp-appserver"
)

DOCKER_COMPOSE="/totvs/hlcloud-stack-imixs-cloud/apps/hlcloud/docker-compose.yml"

#######################################
# 1) PULL EM TODOS OS SERVIDORES
#######################################
for server in $(cat "$SERVER_LIST"); do
  echo "---- Conectando ao servidor: $server ----"
  ssh -i "$SSH_KEY" $SSH_OPTIONS root@"$server" bash -s <<EOF
IMAGES=(${IMAGES[@]})
for img in "\${IMAGES[@]}"; do
  echo "Puxando imagem: \$img"
  if ! docker pull "\$img"; then
    echo "Falha de autenticação detectada. Efetuando login no Azure..."
    az login -u "$AZ_USER" -p "$AZ_PASS" --allow-no-subscriptions >/dev/null 2>&1
    az acr login -n hlcloud >/dev/null 2>&1
    echo "Re-tentando pull: \$img"
    docker pull "\$img" || echo "Ainda falhou: \$img"
  fi
done
EOF
done

#######################################
# 2) ETAPAS APENAS NO MANAGER
#######################################

echo "---- Executando etapas no manager ----"

# Escalar serviços para 0
for svc in "${SERVICES[@]}"; do
  echo "Parando serviço: $svc"
  docker service scale "$svc"=0 || true
done

# Criar backup do docker-compose.yml com data/hora
BACKUP_FILE="${DOCKER_COMPOSE}.$(date +%Y-%m-%d_%H-%M-%S).bak"
cp "$DOCKER_COMPOSE" "$BACKUP_FILE"
echo "Backup criado: $BACKUP_FILE"

# Alterar docker-compose.yml com as novas imagens
for img in "${IMAGES[@]}"; do
  base=$(echo "$img" | cut -d: -f1)   # pega repo/nome
  echo "Atualizando imagem $base para $img"
  sed -i "s|\(image: *$base:\).*|image: $img|" "$DOCKER_COMPOSE"
done

# Recriar o stack
echo "Recriando stack hlcloud..."
docker stack deploy -c "$DOCKER_COMPOSE" hlcloud
