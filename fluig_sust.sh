#!/bin/bash
# Desenvolvido por Alexandre dos Santos (Coxa) - 20-09-2025

# Cria a pasta e baixa os scripts
mkdir -p /volume/CloudFluig && cd /volume/CloudFluig/ || exit 1

# Cria arquivos vazios e aplica permissão
touch verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh import_key.sh
chmod +x verifica_fluig.sh verifica_certificado.sh verifica_solr.sh replicador_fluig.sh import_key.sh

# Baixa os scripts atualizados do GitHub
curl -s -o verifica_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_fluig.sh
curl -s -o verifica_certificado.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_certificado.sh
curl -s -o verifica_solr.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/verifica_solr.sh
curl -s -o replicador_fluig.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/replicador_fluig.sh
curl -s -o import_key.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/import_key.sh
curl -s -o resolve_resend.sh https://raw.githubusercontent.com/alxndresantos/alxndresantos/main/resolve_resend.sh

# Remove bloco antigo do crontab e adiciona novamente
(crontab -l 2>/dev/null | sed '/^#Cloud_sustentação$/,/^#Cloud_sustentação$/d'; cat <<'EOF'
#Cloud_sustentação
*/20 * * * * /bin/bash /volume/CloudFluig/verifica_fluig.sh >> /volume/CloudFluig/verifica_fluig_cron.log 2>&1
0 9 * * * /bin/bash /volume/CloudFluig/verifica_certificado.sh >> /volume/CloudFluig/verifica_certificados_cron.log 2>&1
#* * * * * /bin/bash /volume/CloudFluig/verifica_solr.sh >> /volume/CloudFluig/verifica_solr.log 2>&1
#0 * * * * truncate -s 0 /app/fluig/solr/logs/*.request.log
######PARA O SERVIÇO TCloudDiscovery PARA MITIGAR SOBRECARGA DOS RECURSOS DO SERVIDOR######
0 * * * * systemctl stop tclouddiscovery
######LIMPEZA DE ARQUIVOS ANTIGOS DE UPLOAD######
0 6 * * * find /volume/wdk-data/upload/ -type f -mtime +7 -exec rm -f {} +
#Cloud_sustentação
EOF
) | crontab -
