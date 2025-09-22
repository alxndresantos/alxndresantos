#!/bin/bash
# check_and_install_fluig.sh
# Analisa /var/lib/cloud/instance/custom-data.json e executa o script apropriado
# Se loadbalances estiver vazio ou sem floating_ip -> fluig_sust_std.sh
# Se loadbalances contiver floating_ip -> fluig_sust.sh
# Log em /tmp/install_script_fluig
# Desenvolvido por Alexandre dos Santos (Coxa) - 2025-09-21

JSON_FILE="/var/lib/cloud/instance/custom-data.json"
LOG="/tmp/install_script_fluig"

logit() {
  echo "$(date '+%F %T %z') - $*" >> "$LOG"
}

touch "$LOG" 2>/dev/null || { echo "Falha ao criar $LOG"; exit 1; }

if [ ! -f "$JSON_FILE" ]; then
  logit "ERRO: arquivo $JSON_FILE não encontrado"
  exit 1
fi

# usa jq ou python3 para analisar
if command -v jq >/dev/null 2>&1; then
  HAS_FLOATING=$(jq -r 'if (.loadbalances|type)=="array" then
                          (map(select(has("floating_ip"))) | length > 0)
                        else "false" end' "$JSON_FILE" 2>/dev/null)
  PARSER="jq"
elif command -v python3 >/dev/null 2>&1; then
  HAS_FLOATING=$(python3 - "$JSON_FILE" <<'PY'
import sys, json
fn=sys.argv[1]
try:
    j=json.load(open(fn))
except Exception:
    print("false"); sys.exit(0)
lb=j.get("loadbalances", [])
if isinstance(lb, list) and any(isinstance(x, dict) and "floating_ip" in x for x in lb):
    print("true")
else:
    print("false")
PY
)
  PARSER="python3"
else
  logit "ERRO: nem jq nem python3 disponíveis"
  exit 1
fi

logit "Parser usado: $PARSER. floating_ip encontrado? $HAS_FLOATING"

if [ "$HAS_FLOATING" = "true" ]; then
  SCRIPT_URL="https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust.sh"
  SCRIPT_LOCAL="/tmp/fluig_sust.sh"
  SCRIPT_NAME="fluig_sust.sh"
else
  SCRIPT_URL="https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/fluig_sust_std.sh"
  SCRIPT_LOCAL="/tmp/fluig_sust_std.sh"
  SCRIPT_NAME="fluig_sust_std.sh"
fi

# baixa e executa
logit "Baixando $SCRIPT_URL"
cd /tmp || { logit "Erro ao acessar /tmp"; exit 1; }

if curl -fsSL -o "$SCRIPT_LOCAL" "$SCRIPT_URL"; then
  chmod +x "$SCRIPT_LOCAL" 2>/dev/null || true
  logit "Executando $SCRIPT_NAME"
  if sh "$SCRIPT_LOCAL" >>"$LOG" 2>&1; then
    logit "Execução OK: $SCRIPT_NAME"
  else
    rc=$?
    logit "Execução com erro (exit $rc): $SCRIPT_NAME"
  fi
  rm -f "$SCRIPT_LOCAL"
  logit "Arquivo removido: $SCRIPT_LOCAL"
else
  logit "Falha ao baixar $SCRIPT_URL"
  exit 1
fi

exit 0
