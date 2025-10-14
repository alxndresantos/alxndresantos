#!/usr/bin/env bash
set -euo pipefail

CRED_FILE="/totvs/script/az_credentials"
if [[ -f "$CRED_FILE" ]]; then
  source "$CRED_FILE"
else
  echo "Erro: arquivo $CRED_FILE não encontrado!"
  exit 1
fi

echo ">>> Verificando sessão az..."
if ! az account show >/dev/null 2>&1; then
  echo ">>> Não está logado. Efetuando az login (user)..."
  az login -u "$AZ_USER" -p "$AZ_PASS" --allow-no-subscriptions || {
    echo "ERRO: az login falhou."
    exit 1
  }
else
  echo ">>> Já autenticado na az."
fi

echo ">>> Tentando az acr login -n hlcloud (tentativa automática)..."
if az acr login -n hlcloud >/dev/null 2>&1; then
  echo ">>> az acr login OK"
  exit 0
fi

echo ">>> az acr login falhou. Tentando obter token e fazer docker login manual..."

# tenta obter token e fazer docker login
TOKEN=$(az acr login -n hlcloud --expose-token --output tsv --query accessToken 2>/dev/null || true)
if [[ -z "$TOKEN" ]]; then
  echo "ERRO: não foi possível obter accessToken via 'az acr login --expose-token'."
  echo "Verifique permissões da conta ou use service principal."
  exit 1
fi

# usar um username placeholder; token é o que importa
if echo "$TOKEN" | docker login hlcloud.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password-stdin >/dev/null 2>&1; then
  echo ">>> docker login via token OK"
  exit 0
else
  echo "ERRO: docker login via token falhou."
  echo "Saída de depuração (az account show / az acr show):"
  az account show || true
  az acr show -n hlcloud || true
  exit 1
fi
